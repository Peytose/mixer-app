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
        
        let currentUserSaveQuery = COLLECTION_USERS.document(currentUid).collection("user-saves")
            .whereField("endDate", isGreaterThan: Timestamp(date: Date()))
        let currentUserSavedEvents = try await fetchEvents(for: currentUserSaveQuery, key: key)
        
        if uid == currentUid {
            return currentUserSavedEvents
        } else {
            // Query the "event-saves" subcollection of each event to see if the friend has saved it
            let eventIds = currentUserSavedEvents.compactMap { $0.id }
            
            let queryList = eventIds.compactMap { id in
                return COLLECTION_EVENTS.document(id).collection("event-saves").document(uid)
            }
            
            // Wait for all subcollection queries to complete and combine the results
            var mutualEvents: [CachedEvent] = []
            let group = DispatchGroup()
            for query in queryList {
                group.enter()
                let snapshot = try await query.getDocument()
                if snapshot.exists {
                    if let id = query.parent.parent?.documentID {
                        if let event = currentUserSavedEvents.first(where: { $0.id == id }) {
                            mutualEvents.append(event)
                            group.leave()
                        }
                    }
                }
                
                group.leave()
            }
            
            group.notify(queue: .main) { }
            
            return mutualEvents
        }
    }
    
    
    func fetchPastEvents(for type: PastEventOption, id: String) async throws -> [CachedEvent] {
        let key = "pastEvents-\(id)"
        
        var query: Query {
            switch type {
            case .user:
                return COLLECTION_USERS.document(id).collection("user-history")
                    .whereField("endDate", isLessThanOrEqualTo: Timestamp(date: Date()))
                    .whereField("endDate", isGreaterThanOrEqualTo: Timestamp(date: thirtyDaysBeforeToday))
            case .host:
                return COLLECTION_EVENTS
                    .whereField("hostUid", isEqualTo: id)
                    .whereField("endDate", isLessThanOrEqualTo: Timestamp(date: Date()))
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
        guard let cachedEventIdsDict = cache.readDictionary(forKey: key) as? [String: Date] else {
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
                }
            } else {
                events = documents.compactMap({ try? $0.data(as: Event.self) })
                cachedEvents = events.map { CachedEvent(from: $0.self) }
            }
            
            for event in cachedEvents {
                if let id = event.id {
                    idsDict[id] = Date()
                }
            }
            
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
