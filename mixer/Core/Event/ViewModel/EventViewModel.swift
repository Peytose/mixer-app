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
    @Published var hosts: [Host]?
    @Published var shareURL: URL? = nil
    @Published private (set) var imageLoader: ImageLoader
    @Published var alertItem: AlertItem?
    @Published var favoritesCount: Int = 0
    private var service = UserService.shared

    init(event: Event) {
        self.event = event
        self.imageLoader = ImageLoader(url: event.eventImageUrl)
        
        service.fetchHosts(from: event) { hosts in
            self.hosts = hosts
            self.getEventFavoriteCount()
        }
        
        self.generateShareURL()
    }
    
    
    private func loadImage(for host: Host) -> ImageLoader {
        return ImageLoader(url: host.hostImageUrl)
    }
    
    
    func isUserPartOfEventHosts() -> Bool {
        guard let userHosts = UserService.shared.user?.associatedHosts, let eventHosts = self.hosts else {
            print("Either user hosts or event hosts are nil")
            return false
        }
        let isPartOfHosts = !userHosts.filter { userHost in eventHosts.contains(where: { $0.id == userHost.id }) }.isEmpty
        print("Is user part of event hosts: \(isPartOfHosts)")
        return isPartOfHosts
    }
    
    func getDirectionsToLocation(coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name = event.title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
    
    
    @MainActor func actionForState(_ state: EventUserActionState) {
        switch state {
        case .pastEvent:
            self.toggleFavoriteStatus()
        case .onGuestlist, .pendingJoinRequest:
            self.cancelOrLeaveGuestlist()
        case .inviteOnly, .open:
            self.requestOrJoinGuestlist()
        }
    }

    
    @MainActor func toggleFavoriteStatus() {
        // Negate the current favorite status to toggle it
        let newFavoriteStatus = !(event.isFavorited ?? false)
        
        UserService.shared.toggleFavoriteStatus(isFavorited: newFavoriteStatus,
                                                event: self.event) { error in
            if let error = error {
                print("DEBUG: Error liking event: \(error.localizedDescription)")
                return
            }
            
            self.favoritesCount += newFavoriteStatus ? 1 : -1
            self.event.isFavorited = newFavoriteStatus
            
            HapticManager.playLightImpact()
        }
    }
    
    
    @MainActor func updateFollow(_ isFollowed: Bool) {
        //MARK: WILL UPDATE SOON! (PEYTON)
//        guard let hostId = host?.id else { return }
//        
//        UserService.shared.updateFollowStatus(didFollow: isFollowed, hostUid: hostId) { _ in
//            self.host?.isFollowed = isFollowed
//            HapticManager.playLightImpact()
//        }
    }
    
    
    func requestOrJoinGuestlist() {
        updateGuestlistStatus(with: service.requestOrJoinGuestlist) {
            self.event.didGuestlist = !self.event.isInviteOnly
            self.event.didRequest   = self.event.isInviteOnly
            HapticManager.playSuccess()
        }
    }

    
    func cancelOrLeaveGuestlist() {
        updateGuestlistStatus(with: service.cancelOrLeaveGuestlist) {
            self.event.didGuestlist = false
            self.event.didRequest   = false
            HapticManager.playLightImpact()
        }
    }
    

    private func updateGuestlistStatus(with action: (Event, FirestoreCompletion) -> Void,
                                       completion: @escaping () -> Void) {
        action(event) { error in
            if let error = error {
                print("DEBUG: Error updating guestlist status. \(error.localizedDescription)")
                return
            }
            
            completion()
        }
    }
    
    
    @MainActor func checkIfUserFavoritedEvent() {
        guard let uid = UserService.shared.user?.id else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_USERS
            .document(uid)
            .collection("user-favorites")
            .document(eventId)
            .fetchWithCachePriority(freshnessDuration: 7200) { snapshot, _ in
                guard let isFavorited = snapshot?.exists else { return }
                self.event.isFavorited = isFavorited
            }
    }
    
    
    @MainActor func fetchGuestlistAndRequestStatus() {
        EventManager.shared.fetchGuestlistAndRequestStatus(for: event) { didGuestlist, didRequest in
            self.event.didGuestlist = didGuestlist
            self.event.didRequest   = didRequest
        }
    }
    
    func getEventFavoriteCount() {
        guard let uid = UserService.shared.user?.id else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("event-favorites")
            .count
            .getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    print("DEBUG: error getting favorite event count. \(error.localizedDescription)")
                    return
                }
                
                guard let count =  snapshot?.count as? Int else { return }
                print("DEBUG: count = \(count)")
                DispatchQueue.main.async {
                    self.favoritesCount = count
                }
            }
    }
}

extension EventViewModel {
    func generateShareURL() {
        guard let eventId = event.id else { return }
        
        UniversalLinkManager.generateShareURL(type: .event(eventId),
                                              isPrivateEvent: event.isPrivate) { url in
            DispatchQueue.main.async {
                self.shareURL = url
            }
        }
    }
}
