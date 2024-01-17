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
    
    
    private func fetchEventsByIds(_ ids: [String]) {
        let chunks = ids.chunked(into: 10) // Chunk the array into subarrays of size 10
        let dispatchGroup = DispatchGroup()
        
        for chunk in chunks {
            dispatchGroup.enter()
            let idsString = chunk.joined(separator: ",")
            let queryKey = QueryKey(collectionPath: "events",
                                            filters: ["documentID in [\(idsString)]"])
            
            COLLECTION_EVENTS
                .whereField(FieldPath.documentID(), in: chunk)
                .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 1800) { snapshot, error in
                    if let error = error {
                        print("DEBUG: Error fetching event by ID. \(error.localizedDescription)")
                        return
                    }
                    
                    if let events = self.processSnapshot(snapshot), !events.isEmpty {
                        self.events.formUnion(events)
                    } else {
                        print("DEBUG: No events. Potential error.")
                    }
                }
        }
    }
    
    
    func fetchGuestlistAndRequestStatus(for event: Event, completion: @escaping (Bool, Bool) -> Void) {
        guard let uid = UserService.shared.user?.id else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(uid)
            .fetchWithCachePriority(freshnessDuration: 1800) { snapshot, error in
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
}

// MARK: - Event Fetching
extension EventManager {
    
    func fetchHostMemberEvents() {
        guard let hostIdToMemberTypeMap = UserService.shared.user?.hostIdToMemberTypeMap else { return }
        let hostIds = Array(hostIdToMemberTypeMap.keys)
        let hostIdsString = hostIds.joined(separator: ",")
        
        let queryKey = QueryKey(collectionPath: "events",
                                filters: ["hostIds containsAny [\(hostIdsString)]",
                                          "endDate in Future",
                                          "isPrivate == true"])
                                
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContainsAny: hostIds)
            .whereField("endDate", isGreaterThan: Timestamp())
            .whereField("isPrivate", isEqualTo: true)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 1800) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching host member events. \(error.localizedDescription)")
                    return
                }
                
                if let events = self.processSnapshot(snapshot), !events.isEmpty {
                    self.events.formUnion(events)
                } else {
                    print("DEBUG: No events. Potential error.")
                }
            }
    }
    
    
    func fetchUserSpecificEvents() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let queryKey = QueryKey(collectionPath: "user/accessible-events")
        
        COLLECTION_USERS
            .document(currentUserId)
            .collection("accessible-events")
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 3600) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting event IDs: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.map { $0.documentID }
                
                self.fetchEventsByIds(eventIds)
            }
    }
    
    
    func fetchEvents(for host: Host, completion: @escaping ([Event]) -> Void) {
        guard UserService.shared.user?.associatedHosts?.contains(where: { $0 == host }) ?? false else { return }
        guard let hostId = host.id else { return }
        
        let queryKey = QueryKey(collectionPath: "events",
                                filters: ["hostIds contains \(hostId)"])
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 1800) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching events for \(host.name). \(error.localizedDescription)")
                    return
                }
                
                if let events = self.processSnapshot(snapshot), !events.isEmpty {
                    completion(events)
                } else {
                    print("DEBUG: No events for \(host.name). Potential error.")
                    completion([])
                }
            }
    }
    
    
    func fetchHostCurrentAndFutureEvents(for hostId: String, completion: @escaping ([Event]) -> Void) {
        let queryKey = QueryKey(collectionPath: "events",
                                    filters: ["hostIds contains \(hostId)",
                                              "endDate in Future"])
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isGreaterThan: Timestamp())
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 3600) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching host and current event. \(error.localizedDescription)")
                    return
                }
                
                if let events = self.processSnapshot(snapshot), !events.isEmpty {
                    completion(events)
                } else {
                    print("DEBUG: No events. Potential error.")
                    completion([])
                }
            }
    }
    
    
    func fetchMostRecentEvent(for hostId: String, completion: @escaping ([Event]) -> Void) {
        let queryKey = QueryKey(collectionPath: "events",
                                filters: ["hostIds contains \(hostId)",
                                          "endDate in Past)"],
                                orders: ["endDate descending"],
                                limit: 1)
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isLessThan: Timestamp())
            .order(by: "endDate", descending: true)
            .limit(to: 1)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 3600) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching host and current event. \(error.localizedDescription)")
                    return
                }
                
                if let events = self.processSnapshot(snapshot), !events.isEmpty {
                    completion(events)
                } else {
                    print("DEBUG: No events. Potential error.")
                    completion([])
                }
            }
    }
    
    
    func fetchHostPastEvents(for hostId: String) {
        let queryKey = QueryKey(collectionPath: "events",
                                filters: ["hostIds contains \(hostId)",
                                          "endDate in Past)"])
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isLessThan: Timestamp())
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 86400) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching host past events. \(error.localizedDescription)")
                    return
                }
                
                if let events = self.processSnapshot(snapshot), !events.isEmpty {
                    self.hostPastEvents = events
                } else {
                    print("DEBUG: No events. Potential error.")
                }
            }
    }

    
    func fetchUserPastEvents(for userId: String) {
        let queryKey = QueryKey(collectionPath: "users/events-attended")
        
        COLLECTION_USERS
            .document(userId)
            .collection("events-attended")
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 7200) { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.compactMap({ $0.documentID })
                let dispatchGroup = DispatchGroup()
                var attendedEvents: [Event] = []
                
                for eventId in eventIds {
                    dispatchGroup.enter()
                    
                    COLLECTION_EVENTS
                        .document(eventId)
                        .fetchWithCachePriority(freshnessDuration: 86400) { snapshot, error in
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
    
    
    func fetchAvailableEvents() {
        let queryKey = QueryKey(collectionPath: "events",
                                filters: ["endDate in Future",
                                          "isPrivate == false"])
        
        COLLECTION_EVENTS
            .whereField("endDate", isGreaterThan: Timestamp())
            .whereField("isPrivate", isEqualTo: false)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 3600) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching available events. \(error.localizedDescription)")
                    return
                }
                
                if let events = self.processSnapshot(snapshot), !events.isEmpty {
                    self.events.formUnion(events)
                } else {
                    print("DEBUG: No events. Potential error.")
                }
            }
    }
    
    
    func updateEvent(_ updatedEvent: Event) {
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            events.remove(at: index)
            events.insert(updatedEvent)
        }
    }
}

// MARK: - Event Caching
extension EventManager {
    
}

// MARK: - Utility Functions
extension EventManager {
    
    private func processSnapshot(_ snapshot: QuerySnapshot?) -> [Event]? {
        guard let documents = snapshot?.documents else { return nil }
        var events = documents.compactMap({ try? $0.data(as: Event.self) })
        self.filterUnavailableEvents(events: &events)
        
        return events
    }
    
    
    private func filterUnavailableEvents(events: inout [Event]) {
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
    }
}
