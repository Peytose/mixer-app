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
    
    private var lastFetchedTimestamps: [String: Date] = [:] // EventID to Timestamp
    
    init() {
        self.fetchExploreEvents()
    }
    
    
    func fetchExploreEvents() {
        self.fetchAvailableEvents()
        self.fetchUserSpecificEvents()
        self.fetchHostMemberEvents()
    }
    
    
    private func fetchEvents(from collection: Query, completion: @escaping ([Event]) -> Void) {
        // Attempt to fetch from cache
        collection.getDocuments(source: .cache) { snapshot, error in
            if let error = error {
                print("DEBUG: Error fetching events from cache: \(error.localizedDescription)")
            }

            if let events = self.processSnapshot(snapshot), !events.isEmpty {
                let lastFetchedTimes = events.compactMap { event -> String? in
                    if let id = event.id, let lastFetched = self.lastFetchedTimestamps[id] {
                        return "\(event.title): \(lastFetched)"
                    } else {
                        return nil
                    }
                }.joined(separator: ", ")

                print("DEBUG: Fetched \(events.count) events from CACHE. Last fetched timestamps: [\(lastFetchedTimes)]")
                
                if self.events.allSatisfy(self.isEventFresh) {
                    print("DEBUG: All events from CACHE are fresh.")
                    completion(events) // Use cached data
                } else {
                    print("DEBUG: Some events from CACHE are not fresh. Fetching from SERVER.")
                    self.fetchFromServer(collection, completion: completion)
                }
            } else {
                print("DEBUG: No events in CACHE or CACHE data is stale. Fetching from SERVER.")
                self.fetchFromServer(collection, completion: completion)
            }
        }
    }

    
    private func fetchFromServer(_ collection: Query, completion: @escaping ([Event]) -> Void) {
        collection.getDocuments(source: .server) { snapshot, _ in
            if let events = self.processSnapshot(snapshot, updateTime: true) {
                print("DEBUG: Fetched \(events.count) events from SERVER.")
                completion(events)
            } else {
                print("DEBUG: No events fetched from SERVER.")
            }
        }
    }
    
    
    private func fetchEventsByIds(_ ids: [String]) {
        let chunks = ids.chunked(into: 10) // Chunk the array into subarrays of size 10
        let dispatchGroup = DispatchGroup()
        
        for chunk in chunks {
            dispatchGroup.enter()
            let eventsQuery = COLLECTION_EVENTS
                .whereField(FieldPath.documentID(), in: chunk)
            
            fetchEvents(from: eventsQuery) { events in
                self.events.formUnion(events)
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
}

// MARK: - Event Fetching
extension EventManager {
    
    func fetchHostMemberEvents() {
        guard let hostIdToMemberTypeMap = UserService.shared.user?.hostIdToMemberTypeMap else { return }
        let hostIds = Array(hostIdToMemberTypeMap.keys)
        
        let eventsQuery = COLLECTION_EVENTS
            .whereField("hostIds", arrayContainsAny: hostIds)
            .whereField("endDate", isGreaterThan: Timestamp())
            .whereField("isPrivate", isEqualTo: true)
        
        self.fetchEvents(from: eventsQuery) { events in
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
    
    
    func fetchEvents(for host: Host, completion: @escaping ([Event]) -> Void) {
        guard UserService.shared.user?.associatedHosts?.contains(where: { $0 == host }) ?? false else { return }
        guard let hostId = host.id else { return }
        let hostEventsQuery = COLLECTION_EVENTS.whereField("hostIds", arrayContains: hostId)
        
        fetchEvents(from: hostEventsQuery, completion: completion)
    }
    
    
    func fetchHostCurrentAndFutureEvents(for hostId: String, completion: @escaping ([Event]) -> Void) {
        let hostCurrentAndFutureEventQuery =  COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isGreaterThan: Timestamp())
        
        fetchEvents(from: hostCurrentAndFutureEventQuery, completion: completion)
    }

    
    func fetchHostPastEvents(for hostId: String) {
        let hostPastEventQuery = COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isLessThan: Timestamp())
        
        fetchEvents(from: hostPastEventQuery) { events in
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
    
    
    func fetchAvailableEvents() {
        let availableEventsQuery = COLLECTION_EVENTS
            .whereField("endDate", isGreaterThan: Timestamp())
            .whereField("isPrivate", isEqualTo: false)
        
        fetchEvents(from: availableEventsQuery) { events in
            self.events.formUnion(events)
        }
    }
    
    
    func updateEvent(_ updatedEvent: Event) {
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            events.remove(at: index)
            events.insert(updatedEvent)
            updateLastFetchedTimestamps(for: [updatedEvent])
        }
    }
}

// MARK: - Event Caching
extension EventManager {
    
}

// MARK: - Utility Functions
extension EventManager {
    private func processSnapshot(_ snapshot: QuerySnapshot?, updateTime: Bool = false) -> [Event]? {
        guard let documents = snapshot?.documents else { return nil }
        var events = documents.compactMap({ try? $0.data(as: Event.self) })
        self.filterUnavailableEvents(events: &events)
        
        if updateTime {
            updateLastFetchedTimestamps(for: events)
        }
        
        return events
    }
    
    
    private func updateLastFetchedTimestamps(for events: [Event]) {
        let currentTime = Date()
        events.forEach { event in
            if let id = event.id {
                lastFetchedTimestamps[id] = currentTime
            } else {
                fatalError("ERROR: There's no ID associated with \(event.title)!")
            }
        }
    }
    
    
    private func isEventFresh(_ event: Event) -> Bool {
        guard let id = event.id,
              let lastFetched = lastFetchedTimestamps[id] else { return false }
        let now = Date()
        let freshnessThreshold = 3600.0 // For example, 1 hour in seconds
        return now.timeIntervalSince(lastFetched) < freshnessThreshold
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
