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

final class EventDetailViewModel: ObservableObject {
    @Published var event: CachedEvent
    @Published var host: CachedHost?
    private (set) var coordinates: CLLocationCoordinate2D?

    init(event: CachedEvent) {
        self.event = event
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
                let eventHost = try await HostCache.shared.getHost(from: event.hostUuid)
                DispatchQueue.main.async {
                    self.host = eventHost
                }
            } catch {
                print("DEBUG: Error fetching event host. \(error.localizedDescription)")
            }
        }
    }
    
    
    @MainActor func getEventCoordinates() {
        if event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false { return }
        
        if let longitude = event.longitude, let latitude = event.latitude {
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}
