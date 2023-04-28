//
//  EventDetailViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import CoreLocation
import MapKit

final class EventDetailViewModel: ObservableObject {
    @Published var event: CachedEvent
    @Published var host: CachedHost?
    private (set) var coordinates: CLLocationCoordinate2D?

    init(event: CachedEvent) {
        self.event = event
    }
    
    
    func getDirectionsToLocation(coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name = host?.name ?? event.title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }

    
    func save() {
        guard let uid = AuthViewModel.shared.userSession?.uid, let eventId = event.id else { return }
        
        let eventSavesRef = COLLECTION_EVENTS.document(eventId).collection("event-saves").document(uid)
        let userSavesRef = COLLECTION_USERS.document(uid).collection("user-saves").document(eventId)
        
        let batch = Firestore.firestore().batch()
        batch.setData([uid:true], forDocument: eventSavesRef)
        batch.setData([uid:true], forDocument: userSavesRef)
        
        batch.commit { _ in
            self.event.didSave = true
            Task {
                do {
                    try EventCache.shared.cacheEvent(self.event)
                } catch {
                    print("DEBUG: didSave (save) cache event error! \(error.localizedDescription)")
                }
            }
        }
    }


    func unsave() {
        guard let uid = AuthViewModel.shared.userSession?.uid, let eventId = event.id else { return }
        
        let eventSavesRef = COLLECTION_EVENTS.document(eventId).collection("event-saves").document(uid)
        let userSavesRef = COLLECTION_USERS.document(uid).collection("user-saves").document(eventId)
        
        let batch = Firestore.firestore().batch()
        batch.deleteDocument(eventSavesRef)
        batch.deleteDocument(userSavesRef)
        
        batch.commit { _ in
            self.event.didSave = false
            
            Task {
                do {
                    try EventCache.shared.cacheEvent(self.event)
                } catch {
                    print("DEBUG: didSave (unsave) cache event error! \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor func joinGuestlist() {
        guard let eventId = event.id else { return }
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        UserService.joinGuestlist(eventUid: eventId, user: currentUser) { _ in
            self.event.didGuestlist = true
            
            Task {
                do {
                    try EventCache.shared.cacheEvent(self.event)
                } catch {
                    print("DEBUG: Error caching event after joining guestlist. \(error.localizedDescription)")
                }
            }
            
//            NotificationsViewModel.uploadNotifications(toUid: uid, type: .follow)
        }
    }
    
    @MainActor func followHost() {
        guard let hostId = host?.id else { return }
        
        UserService.follow(hostUid: hostId) { _ in
            self.host?.isFollowed = true
//            NotificationsViewModel.uploadNotifications(toUid: uid, type: .follow)
        }
    }
    
    @MainActor func checkIfUserSavedEvent() {
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_USERS.document(uid).collection("user-saves").document(eventId).getDocument { snapshot, _ in
            guard let didSave = snapshot?.exists else { return }
            self.event.didSave = didSave
        }
    }
    
    
    @MainActor func fetchEventHost() {
        Task {
            do {
                self.host = try await HostCache.shared.getHost(from: event.hostUuid)
            } catch {
                print("DEBUG: Error fetching event host. \(error.localizedDescription)")
            }
        }
    }
    
    
    @MainActor func getEventCoordinates() {
        Task {
            do {
                if event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false { return }
                
                if let longitude = event.longitude, let latitude = event.latitude {
                    self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    print("DEBUG: 1 coordinates on event \(String(describing: self.coordinates))")
                } else {
                    self.coordinates = try await event.address.coordinates()
                    print("DEBUG: 2 coordinates on event \(String(describing: self.coordinates))")
                }
            } catch {
                print("DEBUG: Error getting event coordinates on event view. \(error.localizedDescription)")
            }
        }
    }
}
