//
//  FavoritesViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/8/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FavoritesViewModel: ObservableObject {
    @Published var favoritedEvents = Set<Event>()
    @Published var selectedEvent: Event?
    
    private var listener: ListenerRegistration?
    private var service = UserService.shared
    
    deinit {
        listener?.remove()
    }
    
    
    func actionForState(_ state: EventUserActionState,
                        event: Event) {
        switch state {
        case .pastEvent:
            self.toggleFavoriteStatus(event)
        case .onGuestlist, .pendingJoinRequest:
            self.cancelOrLeaveGuestlist(event)
        case .inviteOnly, .open:
            self.requestOrJoinGuestlist(event)
        }
    }
    
    
    @MainActor
    func startObservingUserFavorites() {
        guard let uid = service.user?.id else { return }
        
        listener = COLLECTION_USERS
            .document(uid)
            .collection("user-favorites")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("DEBUG: Error listening for changes. \(error.localizedDescription)")
                    return
                }
                
                self.favoritedEvents.removeAll()
                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.compactMap({ $0.documentID })
                
                let chunks = eventIds.chunked(into: 10)
                
                for chunk in chunks {
                    let idsString = chunk.joined(separator: ",")
                    let queryKey = QueryKey(collectionPath: "events",
                                                    filters: ["documentID in [\(idsString)]"])
                    
                    COLLECTION_EVENTS
                        .whereField(FieldPath.documentID(), in: chunk)
                        .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 1800) { snapshot, error in
                            if let error = error {
                                print("DEBUG: Error getting events. \(error.localizedDescription)")
                                return
                            }
                            
                            guard let eventDocuments = snapshot?.documents else { return }
                            let events = eventDocuments.compactMap({ try? $0.data(as: Event.self) })
                            
                            for var event in events {
                                event.isFavorited = true
                                
                                if event.isCheckInViaMixer {
                                    EventManager.shared.fetchGuestlistAndRequestStatus(for: event) { didGuestlist, didRequest in
                                        event.didGuestlist = didGuestlist
                                        event.didRequest   = didRequest
                                        self.favoritedEvents.insert(event)
                                    }
                                } else {
                                    self.favoritedEvents.insert(event)
                                }
                            }
                        }
                }
            }
    }
    
    
    func formattedEventSubtitle(_ event: Event) -> String {
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
    

    func requestOrJoinGuestlist(_ event: Event) {
        updateGuestlistStatus(for: event,
                              with: service.requestOrJoinGuestlist) {
            self.adjustEventForGuestStatus(event, isRequestOrJoin: true)
            HapticManager.playSuccess()
        }
    }

    
    func cancelOrLeaveGuestlist(_ event: Event) {
        updateGuestlistStatus(for: event,
                              with: service.cancelOrLeaveGuestlist) {
            self.adjustEventForGuestStatus(event, isRequestOrJoin: false)
            HapticManager.playLightImpact()
        }
    }

    
    private func adjustEventForGuestStatus(_ event: Event, isRequestOrJoin: Bool) {
        var newEvent: Event = event
        
        if isRequestOrJoin {
            newEvent.didGuestlist = !event.isInviteOnly
            newEvent.didRequest   = event.isInviteOnly
        } else {
            newEvent.didGuestlist = false
            newEvent.didRequest   = false
        }
        
        self.favoritedEvents.insert(newEvent)
    }

    
    private func updateGuestlistStatus(for event: Event, with action: (Event, FirestoreCompletion) -> Void, completion: @escaping () -> Void) {
        action(event) { error in
            if let error = error {
                print("DEBUG: Error updating guestlist status. \(error.localizedDescription)")
                return
            }
            
            self.favoritedEvents.remove(event)
            completion()
        }
    }
    
    
    func toggleFavoriteStatus(_ event: Event) {
        let status = event.isFavorited ?? false
        
        self.service.toggleFavoriteStatus(isFavorited: !status,
                                          event: event) { error in
            if let error = error {
                print("DEBUG: Error toggling favorite status: \(error.localizedDescription)")
                return
            }
            
            HapticManager.playLightImpact()
        }
    }
}
