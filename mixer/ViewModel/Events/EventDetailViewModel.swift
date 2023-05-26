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
    @Published var event: CachedEvent {
        didSet {
            EventCache.shared.cacheEvent(event)
        }
    }
    @Published var host: CachedHost?
    private (set) var coordinates: CLLocationCoordinate2D?
    @Published var isDataReady: Bool = false
    @Published private (set) var imageLoader: ImageLoader

    init(event: CachedEvent) {
        self.event = event
        self.imageLoader = ImageLoader(url: event.eventImageUrl)
        
        Task.init {
            await checkIfUserLikedEvent()
            await fetchEventHost()
            await getEventCoordinates()
            
            DispatchQueue.main.async {
                self.isDataReady = true
            }
        }
    }
    
    private func loadHostImage() -> ImageLoader {
        return ImageLoader(url: self.host?.hostImageUrl ?? "")
    }
    
    
    func getDirectionsToLocation(coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name = event.title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }

    
    func updateLike(didLike: Bool) {
        guard let eventId = event.id else { return }
        
        UserService.updateLikeStatus(didLike: didLike, eventUid: eventId) { error in
            if let error = error {
                print("DEBUG: ❌ Error liking event. \(error.localizedDescription)")
                return
            }
            
            HapticManager.playLightImpact()
            self.event.didLike = didLike
            EventCache.shared.cacheEvent(self.event)
        }
    }
    
    
    @MainActor func joinGuestlist() {
        guard let eventId = event.id else { return }
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        UserService.joinGuestlist(eventUid: eventId, user: currentUser) { _ in
            self.event.didGuestlist = true
            
//            NotificationsViewModel.uploadNotifications(toUid: uid, type: .follow)
        }
    }
    
    
    private func checkIfHostIsFollowed() {
        print("DEBUG: Checking if host is followed ... ")
        
        if let host = self.host, let hostId = host.id {
           UserService.checkIfHostIsFollowed(hostUid: hostId) { isFollowed in
               self.host?.isFollowed = isFollowed
               print("DEBUG: You do\(isFollowed ? "" : " not") follow this host!")
               HostCache.shared.cacheHost(host)
           }
       }
    }
    
    
    @MainActor func followHost() {
        guard let hostId = host?.id else { return }
        
        UserService.follow(hostUid: hostId) { _ in
            self.host?.isFollowed = true
            HapticManager.playLightImpact()
//            NotificationsViewModel.uploadNotifications(toUid: , type: .follow)
        }
    }
    
    
    @MainActor func unfollowHost() {
        guard let hostId = host?.id else { return }
        
        UserService.unfollow(hostUid: hostId) { _ in
            self.host?.isFollowed = false
            HapticManager.playLightImpact()
        }
    }
    
    
    @MainActor func checkIfUserLikedEvent() {
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_USERS.document(uid).collection("user-likes").document(eventId).getDocument { snapshot, _ in
            guard let didLike = snapshot?.exists else { return }
            self.event.didLike = didLike
            EventCache.shared.cacheEvent(self.event)
        }
    }
    
    
    @MainActor func fetchEventHost() {
        Task {
            do {
                self.host = try await HostCache.shared.getHost(from: event.hostUuid)
                checkIfHostIsFollowed()
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
                    print("DEBUG: Found coordinates on event \(String(describing: self.coordinates))")
                } else {
                    self.coordinates = try await event.address.coordinates()
                    print("DEBUG: Fetched coordinates on event \(String(describing: self.coordinates))")
                    EventCache.shared.cacheEvent(self.event)
                }
            } catch {
                print("DEBUG: Error getting event coordinates on event view. \(error.localizedDescription)")
            }
        }
    }
}
