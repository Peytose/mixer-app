//
//  EventManager.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class EventManager: ObservableObject {
    static let shared = EventManager()
    @Published var selectedEvent: Event?
    @Published var events         = Set<Event>()
    @Published var hostPastEvents = [Event]()
    @Published var userPastEvents = [Event]()
    
    init() {
        self.fetchExploreEvents()
    }
    
    
    func fetchExploreEvents() {
        self.fetchAvailableEvents()
        self.fetchUserSpecificEvents()
        self.fetchHostMemberEvents()
    }
    
    
    func fetchHostMemberEvents() {
        guard let hostId = UserService.shared.user?.currentHost?.id else { return }
        
        let eventsQuery = COLLECTION_EVENTS.whereField("hostIds", arrayContains: hostId).whereField("endDate", isGreaterThan: Timestamp())
        
        self.fetchAndFilterEvents(from: eventsQuery) { events in
            self.events.formUnion(events)
        }
    }
    
    
    func fetchUserSpecificEvents() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS
            .document(currentUserId)
            .collection("accessible-events")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting event IDs: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.map { $0.documentID }

                self.fetchEventsByIds(eventIds)
            }
    }

    
    private func fetchEventsByIds(_ ids: [String]) {
        let chunks = ids.chunked(into: 10) // Chunk the array into subarrays of size 10
        let dispatchGroup = DispatchGroup()

        for chunk in chunks {
            dispatchGroup.enter()
            let eventsQuery = COLLECTION_EVENTS
                .whereField(FieldPath.documentID(), in: chunk)
            
            fetchAndFilterEvents(from: eventsQuery) { events in
                self.events.formUnion(events)
            }
        }
    }

    
    func fetchAvailableEvents() {
        let availableEventsQuery = COLLECTION_EVENTS
            .whereField("endDate", isGreaterThan: Timestamp())
            .whereField("isPrivate", isEqualTo: false)

        fetchAndFilterEvents(from: availableEventsQuery) { events in
            self.events.formUnion(events)
        }
    }
    
    
    private func fetchAndFilterEvents(from collection: Query, completion: @escaping ([Event]) -> Void) {
        collection.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Error getting events: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            let events = documents.compactMap({ try? $0.data(as: Event.self) })

            // Filter out events that have planners that are pending or declined
            var filteredEvents = events.filter { event in
                for (_, status) in event.plannerHostStatusMap {
                    if status == .pending || status == .declined {
                        return false
                    }
                }
                return true
            }
            
            // Ensure to remove events that have ended
            filteredEvents.removeAll(where: { $0.endDate < Timestamp() })

            completion(filteredEvents)
        }
    }
    
    
    func getGuestlistAndRequestStatus(for event: Event, completion: @escaping (Bool, Bool) -> Void) {
        guard let uid = UserService.shared.user?.id else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let data = snapshot?.data() else {
                    completion(false, false)
                    return
                }
                
                let guestStatus = GuestStatus(rawValue: data["status"] as? Int ?? -1)
                
                let didGuestlist = guestStatus != .requested
                let didRequest = guestStatus == .requested
                
                completion(didGuestlist, didRequest)
            }
    }
    
    
    func fetchEvents(for host: Host, completion: @escaping ([Event]) -> Void) {
        guard UserService.shared.user?.associatedHosts?.contains(where: { $0 == host }) ?? false else { return }
        guard let hostId = host.id else { return }
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting events for \(host.name). \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                completion(events)
            }
    }
    
    
    func fetchHostCurrentAndFutureEvents(for hostId: String, completion: @escaping ([Event]) -> Void) {
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isGreaterThan: Timestamp())
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting host events: \(error.localizedDescription)")
                    return
                }
                
                print("DEBUG: No error")
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                print("DEBUG: Not the compact map")
                completion(events)
            }
    }

    
    func fetchHostPastEvents(for hostId: String) {
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isLessThan: Timestamp())
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting host past events: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                self.hostPastEvents = events
            }
    }

    
    func fetchUserPastEvents(for userId: String) {
        COLLECTION_USERS
            .document(userId)
            .collection("events-attended")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.compactMap({ $0.documentID })
                let dispatchGroup = DispatchGroup()
                var attendedEvents: [Event] = []
                
                for eventId in eventIds {
                    dispatchGroup.enter()
                    
                    COLLECTION_EVENTS
                        .document(eventId)
                        .getDocument { snapshot, error in
                            if let error = error {
                                print("DEBUG: Error getting host past events: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let snapshot = snapshot else { return }
                            guard let event = try? snapshot.data(as: Event.self) else { return }
                            attendedEvents.append(event)
                            
                            dispatchGroup.leave()
                        }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.userPastEvents = attendedEvents
                }
                
            }
    }
}

