//
//  EventCache.swift
//  mixer
//
//  Created by Peyton Lyons on 2/5/23.
//

import SwiftUI
import FirebaseFirestore
import DataCache
import CryptoKit

class EventCache {
    static let shared = EventCache()
    private init() { configureCache() }
    private let cache = DataCache(name: "EventCache")
    private let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    
    private func configureCache() {
        cache.maxDiskCacheSize = 100 * 1024 * 1024    // 100 MB
        cache.maxCachePeriodInSecond = 60 * 60        // 60 mins
    }
    
    
    enum PastEventOption {
        case user
        case host
    }
    
    
    func fetchSavedEvents(for uid: String) async throws -> [CachedEvent] {
        let key = "savedEvents-\(uid)"
        guard let currentUid = AuthViewModel.shared.currentUser?.id else { return [] }
        
        let currentUserSavesQuery = COLLECTION_USERS.document(currentUid).collection("user-saves")
        let currentUserEvents = try await fetchEvents(for: currentUserSavesQuery, key: "savedEvents-\(currentUid)")
        let currentUserSavedIds = currentUserEvents.filter({ $0.endDate.dateValue() > Date() }).compactMap { $0.id }
        
        if uid == currentUid {
            return currentUserEvents
        } else {
            let queryList = currentUserSavedIds.compactMap { id in
                return COLLECTION_EVENTS.document(id).collection("event-saves").document(uid)
            }
            
            var mutualEvents = [CachedEvent]()
            let group = DispatchGroup()
            
            for query in queryList {
                group.enter()
                let snapshot = try await query.getDocument()
                if snapshot.exists {
                    if let eventId = query.parent.parent?.documentID {
                        mutualEvents.append(try await getEvent(withId: eventId))
                    }
                }
                
                group.leave()
            }
            
            group.notify(queue: .main) { }
            
            return mutualEvents
        }
    }
    
    
    func updateSavedCache(event: CachedEvent, isSaving: Bool, key: String) async throws {
        try EventCache.shared.cacheEvent(event)
        
        if let eventId = event.id {
            guard var cachedEventIdsDict = cache.readDictionary(forKey: key) as? [String: Date], !cachedEventIdsDict.isEmpty else {
                if isSaving {
                    let dictionary = [eventId: Date()]
                    EventCache.shared.cache.write(dictionary: dictionary, forKey: key)
                }
                
                return
            }
            
            if isSaving {
                cachedEventIdsDict[eventId] = Date()
                EventCache.shared.cache.write(dictionary: cachedEventIdsDict, forKey: key)
            } else {
                EventCache.shared.cache.write(dictionary: cachedEventIdsDict.filter({ $0.key != eventId }), forKey: key)
            }
        }
    }
    
    
    func fetchPastEvents(for type: PastEventOption, id: String) async throws -> [CachedEvent] {
        let key = "pastEvents-\(id)"
        
        var query: Query {
            switch type {
            case .user:
                return COLLECTION_USERS.document(id).collection("user-history")
                    .whereField("endDate", isLessThanOrEqualTo: Timestamp())
                    .whereField("endDate", isGreaterThanOrEqualTo: Timestamp(date: thirtyDaysBeforeToday))
            case .host:
                return COLLECTION_EVENTS
                    .whereField("hostUid", isEqualTo: id)
                    .whereField("endDate", isLessThanOrEqualTo: Timestamp())
                    .whereField("endDate", isGreaterThanOrEqualTo: Timestamp(date: thirtyDaysBeforeToday))
            }
        }
        
        return try await fetchEvents(for: query, key: key)
    }
    
    
    func fetchTodayEvents() async throws -> [CachedEvent] {
        let key = "todayEvents"
        
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let startOfToday = Calendar.current.startOfDay(for: today)
        let endOfToday = Calendar.current.startOfDay(for: tomorrow)

        let query = COLLECTION_EVENTS
            .whereField("startDate", isGreaterThanOrEqualTo: Timestamp(date: startOfToday))
            .whereField("startDate", isLessThan: Timestamp(date: endOfToday))
        
        return try await fetchEvents(for: query, key: key)
    }
    
    
    func fetchFutureEvents() async throws -> [CachedEvent] {
        let key = "futureEvents"
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let endOfToday = Calendar.current.startOfDay(for: tomorrow)
        
        let query = COLLECTION_EVENTS
            .whereField("startDate", isGreaterThan: Timestamp(date: endOfToday))
        
        return try await fetchEvents(for: query, key: key)
    }
    
    
    private func fetchEvents(for query: Query, key: String) async throws -> [CachedEvent] {
        guard let cachedEventIdsDict = cache.readDictionary(forKey: key) as? [String: Date], !cachedEventIdsDict.isEmpty else {
            return try await getFromFirebaseAndCache(for: query, key: key)
        }
        
        print("DEBUG: Got cached Events Ids Dict. \(cachedEventIdsDict)")
        let expirationInterval: TimeInterval = 60 * 60 // 1 hour
        let now = Date()
        
        let expiredEvents = cachedEventIdsDict.filter { now.timeIntervalSince($0.value) > expirationInterval }
        print("DEBUG: Expired events : \(expiredEvents)")
        
        if !expiredEvents.isEmpty {
            return try await getFromFirebaseAndCache(for: query, key: key)
        }
        
        var events = [CachedEvent]()
        
        for id in cachedEventIdsDict.keys {
            events.append(try await getEvent(withId: id))
        }
        
        print("DEBUG: Events from CACHE for key : \(key). \(events)")
        return events
    }
    
    
    private func getFromFirebaseAndCache(for query: Query, key: String) async throws -> [CachedEvent] {
        let snapshot = try await query.getDocuments()
        let documents = snapshot.documents
        if !documents.isEmpty {
            print("DEBUG: Got documents. \(String(describing: documents.first?.data()))")
            // Store ids
            var idsDict      = [String: Date]()
            var events       = [Event]()
            var cachedEvents = [CachedEvent]()
            
            if key.hasPrefix("savedEvents-") {
                let eventIds = documents.compactMap { $0.documentID }
                
                for id in eventIds {
                    cachedEvents.append(try await getEvent(withId: id))
                    idsDict[id] = Date()
                }
            } else {
                events = documents.compactMap({ try? $0.data(as: Event.self) })
                print("DEBUG: \(events)")
                cachedEvents = events.map { CachedEvent(from: $0.self) }
                print("DEBUG: \(cachedEvents)")
                
                for var event in cachedEvents {
                    if let id = event.id {
                        if let coords = try await event.address.coordinates() {
                            print("DEBUG: event coords. \(coords)")
                            event.latitude = coords.latitude
                            event.longitude = coords.longitude
                            
                            if let existingEventIndex = cachedEvents.firstIndex(where: { $0.id == event.id }) {
                                cachedEvents.remove(at: existingEventIndex)
                                cachedEvents.append(event)
                            }
                        }
                        
                        idsDict[id] = Date()
                    }
                }
            }
            
            print("DEBUG: \(cachedEvents)")
            
            print("DEBUG: ids Dict \(idsDict)")
            
            // Store in cache
            cache.clean(byKey: key)
            cache.write(dictionary: idsDict, forKey: key)
            try await cacheEvents(cachedEvents)
            
            return cachedEvents
        } else {
            print("DEBUG: This query \(query) did not yield results from Firebase.")
            return []
        }
    }
    
    
    func clearCache() {
        cache.cleanDiskCache()
    }
    
    
    func getEvent(withId id: String) async throws -> CachedEvent {
        // Check cache for event
        if let event: CachedEvent = try cache.readCodable(forKey: id) {
            return event
        }
        
        // If event not found in cache, fetch from Firebase
        let snapshot = try await COLLECTION_EVENTS.document(id).getDocument()
        let event = try snapshot.data(as: Event.self)
        
        // Store in cache
        let cachedEvent = CachedEvent(from: event)
        try cacheEvent(cachedEvent)
        
        return cachedEvent
    }
    
    
    private func cacheEvents(_ events: [CachedEvent]) async throws {
        for event in events { try cacheEvent(event) }
    }
    
    
    func cacheEvent(_ event: CachedEvent) throws {
        guard let id = event.id else { return }
        try cache.write(codable: event, forKey: id)
    }
}
