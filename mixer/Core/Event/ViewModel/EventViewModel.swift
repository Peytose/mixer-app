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
    
    private var service = UserService.shared

    init(event: Event) {
        self.event = event
        self.imageLoader = ImageLoader(url: event.eventImageUrl)
        
        service.fetchHosts(from: event) { hosts in
            self.hosts = hosts
        }
        
        self.generateShareURL()
    }
    
    
    private func loadImage(for host: Host) -> ImageLoader {
        return ImageLoader(url: host.hostImageUrl)
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
        case .requestToJoin, .open:
            self.requestOrJoinGuestlist()
        default:
            break
        }
    }

    
    @MainActor func toggleFavoriteStatus() {
        // Negate the current favorite status to toggle it
        let newFavoriteStatus = !(event.isFavorited ?? false)
        
        UserService.shared.toggleFavoriteStatusStatus(isFavorited: newFavoriteStatus,
                                                event: event) { _ in
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
            self.adjustEventForGuestStatus(isRequestOrJoin: true)
            HapticManager.playSuccess()
        }
    }

    func cancelOrLeaveGuestlist() {
        updateGuestlistStatus(with: service.cancelOrLeaveGuestlist) {
            self.adjustEventForGuestStatus(isRequestOrJoin: false)
            HapticManager.playLightImpact()
        }
    }

    private func adjustEventForGuestStatus(isRequestOrJoin: Bool) {
        let guestStatus: GuestStatus = event.isManualApprovalEnabled ? .requested : .invited
        
        if isRequestOrJoin {
            self.event.didGuestlist = guestStatus == .invited
            self.event.didRequest   = guestStatus == .requested
        } else {
            self.event.didGuestlist = false
            self.event.didRequest   = false
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
    
    
    func toggleFavoriteStatus(_ event: Event) {
        let status = event.isFavorited ?? false
        
        self.service.toggleFavoriteStatusStatus(isFavorited: !status,
                                          event: event) { _ in
            HapticManager.playLightImpact()
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
    
    
    @MainActor func getGuestlistAndRequestStatus() {
        EventManager.shared.getGuestlistAndRequestStatus(for: event) { didGuestlist, didRequest in
            self.event.didGuestlist = didGuestlist
            self.event.didRequest   = didRequest
        }
    }
}

extension EventViewModel {
    func generateShareURL() {
        guard let eventId = event.id else {
            self.shareURL = nil
            return
        }
        
        let baseURL = "mixerapp://open-event?id=\(eventId)"
        
        if event.isPrivate {
            generateEventToken { token in
                guard let token = token else {
                    self.shareURL = nil
                    return
                }
                
                let fullURLString = baseURL + "&token=\(token)"
                self.shareURL = URL(string: fullURLString)
            }
        } else {
            self.shareURL = URL(string: baseURL)
        }
    }
    
    
    private func generateEventToken(completion: @escaping (String?) -> Void) {
        guard let eventId = event.id else {
            completion(nil)
            return
        }
        
        let url = URL(string: "https://us-central1-your-firebase-project-name.cloudfunctions.net/generateEventToken")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let requestBody: [String: Any] = ["eventId": eventId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error:", error)
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = jsonResponse["token"] as? String {
                        completion(token)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON:", error)
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
}
