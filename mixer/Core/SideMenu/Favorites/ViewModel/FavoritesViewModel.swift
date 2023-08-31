//
//  FavoritesViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/8/23.
//

import SwiftUI
import Firebase

class FavoritesViewModel: ObservableObject {
    @Published var favoritedEvents = Set<Event>()
    @Published var selectedEvent: Event?
    
    private var listener: ListenerRegistration?
    private var service = UserService.shared
    
    deinit {
        listener?.remove()
    }
    
    @MainActor
    func startListeningForFavorites() {
        guard let uid = service.user?.id else { return }
        
        listener = COLLECTION_USERS
            .document(uid)
            .collection("user-favorites")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("DEBUG: Error listening for changes. \(error.localizedDescription)")
                    return
                }
                
                self?.favoritedEvents.removeAll()
                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.compactMap({ $0.documentID })
                
                let chunks = eventIds.chunked(into: 10)
                
                for chunk in chunks {
                    COLLECTION_EVENTS
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("DEBUG: Error getting events. \(error.localizedDescription)")
                                return
                            }
                            
                            guard let eventDocuments = snapshot?.documents else { return }
                            let events = eventDocuments.compactMap({ try? $0.data(as: Event.self) })
                            
                            for var event in events {
                                event.isFavorited = true
                                
                                if event.isGuestlistEnabled {
                                    EventManager.shared.checkIfUserIsOnGuestlist(for: event) { didGuestlist in
                                        event.didGuestlist = didGuestlist
                                        self?.favoritedEvents.insert(event)
                                    }
                                } else {
                                    self?.favoritedEvents.insert(event)
                                }
                            }
                        }
                }
            }
    }
    
    
    func getSubtitleString(_ event: Event) -> String {
        let text = event.type.description
        let startDate = event.startDate
        let endDate = event.endDate
        
        if endDate < Timestamp() {
            return text + " ended on \(startDate.getTimestampString(format: "MMM d, yyyy"))"
        } else if event.isEventCurrentlyHappening() {
            return text + " ends @ \(startDate.getTimestampString(format: "h:mm, a"))"
        } else {
            return text + " starts \(startDate.getTimestampString(format: "MMM d, h:mm a"))"
        }
       
    }
    

    func joinGuestlist(_ event: Event) {
        updateGuestlistStatus(for: event,
                              action: service.joinGuestlist,
                              didGuestlist: true,
                              haptic: HapticManager.playSuccess)
    }
    

    func leaveGuestlist(_ event: Event) {
        updateGuestlistStatus(for: event,
                              action: service.leaveGuestlist,
                              didGuestlist: false,
                              haptic: HapticManager.playLightImpact)
    }
    
    
    private func updateGuestlistStatus(for event: Event,
                                       action: (Event, FirestoreCompletion) -> Void,
                                       didGuestlist: Bool,
                                       haptic: @escaping () -> Void) {
        action(event) { error in
            if let error = error {
                print("DEBUG: Error updating guestlist status. \(error.localizedDescription)")
                return
            }
            
            self.favoritedEvents.remove(event)
            var newEvent = event
            newEvent.didGuestlist = didGuestlist
            self.favoritedEvents.insert(newEvent)
            haptic()
        }
    }
    
    
    func updateFavorite(_ event: Event) {
        let status = event.isFavorited ?? false
        
        self.service.updateFavoriteStatus(isFavorited: !status,
                                          event: event) { _ in
            HapticManager.playLightImpact()
        }
    }
}
