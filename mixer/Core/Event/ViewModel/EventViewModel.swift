//
//  EventViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import CoreLocation
import MapKit

final class EventViewModel: ObservableObject {
    @Published var event: Event
    @Published var host: Host?
    @Published private (set) var imageLoader: ImageLoader
    @Published var alertItem: AlertItem?

    init(event: Event) {
        self.event = event
        self.imageLoader = ImageLoader(url: event.eventImageUrl)
        self.fetchHost(from: event)
    }
    
    
    private func loadHostImage() -> ImageLoader {
        return ImageLoader(url: self.host?.hostImageUrl ?? "")
    }
    
    
    func fetchHost(from event: Event) {
        COLLECTION_HOSTS
            .document(event.hostId)
            .getDocument { snapshot, _ in
                guard let host = try? snapshot?.data(as: Host.self) else { return }
                self.host = host
            }
    }
    
    
    func getDirectionsToLocation(coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name = event.title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }

    
    @MainActor func updateFavorite() {
        guard let eventId = event.id else { return }
        
        // Negate the current favorite status to toggle it
        let newFavoriteStatus = !(event.isFavorited ?? false)
        
        UserService.shared.updateFavoriteStatus(isFavorited: newFavoriteStatus, eventId: eventId) { _ in
            self.event.isFavorited = newFavoriteStatus
            HapticManager.playLightImpact()
        }
    }
    
    
    @MainActor func updateFollow(_ isFollowed: Bool) {
        guard let hostId = host?.id else { return }
        
        UserService.shared.updateFollowStatus(didFollow: isFollowed, hostUid: hostId) { _ in
            self.host?.isFollowed = isFollowed
            HapticManager.playLightImpact()
        }
    }
    
    
//    @MainActor func joinGuestlist() {
//        guard let eventId = event.id else { return }
//        guard let currentUser = UserService.shared.user else { return }
//
//        UserService.joinGuestlist(eventUid: eventId, user: currentUser) { _ in
//            self.event.didGuestlist = true
//        }
//    }
    
    
    @MainActor func checkIfHostIsFollowed() {
        guard let hostId = host?.id else { return }
        guard let currentUid = UserService.shared.user?.id else { return }
        
        UserService.shared.checkIfHostIsFollowed(forId: hostId) { isFollowed in
            self.host?.isFollowed = isFollowed
        }
    }
    
    
    @MainActor func checkIfUserFavoritedEvent() {
        guard let uid = UserService.shared.user?.id else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_USERS.document(uid).collection("user-favorites").document(eventId).getDocument { snapshot, _ in
            guard let isFavorited = snapshot?.exists else { return }
            self.event.isFavorited = isFavorited
        }
    }
    
    
    @MainActor func checkIfUserIsOnGuestlist() {
        guard let uid = UserService.shared.user?.id else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("gueslist")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let didGuestlist = snapshot?.exists else { return }
                self.event.didGuestlist = didGuestlist
            }
    }
    
    
    @MainActor func fetchEventHost() {
        COLLECTION_HOSTS
            .document(event.hostId)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                guard let host = try? snapshot.data(as: Host.self) else { return }
                self.host = host
                self.checkIfHostIsFollowed()
            }
    }
}
