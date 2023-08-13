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

    
    @MainActor func updateFavorite(_ isFavorited: Bool) {
        guard let eventId = event.id else { return }
        
        UserService.shared.updateFavoriteStatus(didFavorite: isFavorited, eventUid: eventId) { _ in
            self.event.didFavorite = isFavorited
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
//        guard let currentUser = AuthViewModel.shared.currentUser else { return }
//
//        UserService.joinGuestlist(eventUid: eventId, user: currentUser) { _ in
//            self.event.didGuestlist = true
//        }
//    }
    
    
    @MainActor func checkIfHostIsFollowed() {
        guard let hostId = host?.id else { return }
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        
        UserService.shared.checkIfHostIsFollowed(forId: hostId) { isFollowed in
            self.host?.isFollowed = isFollowed
        }
    }
    
    
    @MainActor func checkIfUserFavoritedEvent() {
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_USERS.document(uid).collection("user-favorites").document(eventId).getDocument { snapshot, _ in
            guard let didFavorite = snapshot?.exists else { return }
            self.event.didFavorite = didFavorite
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
