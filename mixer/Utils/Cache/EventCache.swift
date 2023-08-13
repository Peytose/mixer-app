////
////  EventCache.swift
////  mixer
////
////  Created by Peyton Lyons on 2/5/23.
////
//
//import SwiftUI
//import FirebaseFirestore
//import DataCache
//import CryptoKit
//
//class EventCache {
//    static let shared = EventCache()
//    private init() { configureCache() }
//    private let cache = DataCache(name: "EventCache")
//
//    enum EventFilterOption {
//        case pastUser(uid: String, fromDate: Date)
//        case hostEvents(uid: String)
//        case unfinished
//        case userLikes(uid: String)
//        case all
//
//        var filterKey: String {
//            switch self {
//            case .pastUser(uid: let uid, fromDate: _):
//                return "past-\(uid)"
//            case .hostEvents(uid: let uid):
//                return "events-\(uid)"
//            case .unfinished:
//                return "unfinished-events"
//            case .userLikes(uid: let uid):
//                return "likes-\(uid)"
//            case .all:
//                return "events"
//            }
//        }
//
//        func query() -> Query {
//            let today = Date()
//            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
//
//            switch self {
//            case .pastUser(uid: let uid, fromDate: let fromDate):
//                return COLLECTION_USERS.document(uid).collection("user-history")
//                    .whereField("endDate", isLessThanOrEqualTo: Timestamp())
//                    .whereField("endDate", isGreaterThanOrEqualTo: Timestamp(date: fromDate))
//                    .order(by: "startDate", descending: true)
//            case .hostEvents(uid: let uid):
//                return COLLECTION_EVENTS
//                    .whereField("hostId", isEqualTo: uid)
//                    .whereField("endDate", isGreaterThan: Timestamp())
//            case .unfinished:
//                return COLLECTION_EVENTS
//                    .whereField("endDate", isGreaterThan: Timestamp())
//            case .userLikes(uid: let uid):
//                return COLLECTION_USERS.document(uid).collection("user-likes")
//                    .order(by: "timestamp", descending: true)
//            case .all:
//                return COLLECTION_EVENTS
//                    .order(by: "startDate", descending: true)
//            }
//        }
//    }
//
//
//    private func configureCache() {
//        cache.maxDiskCacheSize = 100 * 1024 * 1024    // 100 MB
//        cache.maxCachePeriodInSecond = 60 * 60        // 60 mins
//    }
//
//    // Cache Key Generation
//    private func getKey(for filter: EventFilterOption) -> String {
//        return filter.filterKey
//    }
//
//    // Fetching Events
//    func fetchEvents(filter: EventFilterOption) async throws -> [Event] {
//        let query = filter.query()
//        let key = getKey(for: filter)
//        print("DEBUG: Filter option: \(filter)")
//        return try await fetchEvents(for: query, key: key)
//    }
//
//    private func fetchEvents(for query: Query, key: String) async throws -> [Event] {
//        // Check if the cached event ids exist and are not empty
//        if let EventIds: [String] = try cache.readCodable(forKey: key), !EventIds.isEmpty {
//            print("DEBUG: Cached event ids for \(key). \(EventIds)")
//            return try await getEvents(from: EventIds)
//        } else {
//            // Fetch documents from Firestore
//            let snapshot = try await query.getDocuments()
//            let documents = snapshot.documents
//            print("DEBUG: document from fetching event: \(String(describing: documents.first?.data()))")
//
//            // If documents exist, cache and return the events
//            if !documents.isEmpty {
//                if key.prefix(5) == "likes" {
//                    // Fetch UUIDs and then fetch the associated events
//                    let uuids = documents.map { $0.documentID }
//                    return try await getEvents(from: uuids)
//                }
//
//                let events = documents.compactMap { document -> Event? in
//                    do {
//                        let event = try document.data(as: Event.self)
//                        return Event(from: event)
//                    } catch let error {
//                        print("Error decoding event: \(error)")
//                        return nil
//                    }
//                }
//
//                let eventIds = events.map({ $0.id })
//                print("DEBUG: Got events from firebase. \(events)")
//                try cache.write(codable: eventIds, forKey: key)
//                self.cacheEvents(events)
//
//                return events
//            } else {
//                // If no documents exist, return an empty array
//                // Also remove the cached event ids to avoid returning an empty result next time
////                cache.clean(byKey: key)
//                return []
//            }
//        }
//    }
//
//
//    // Getting Events
//    func getEvents(from eventIds: [String]) async throws -> [Event] {
//        var Events = [Event]()
//        await withTaskGroup(of: Event?.self) { group in
//            for eventId in eventIds {
//                group.addTask {
//                    do {
//                        return try await self.getEvent(from: eventId)
//                    } catch {
//                        print("Error getting event: \(error)")
//                        return nil
//                    }
//                }
//            }
//
//            for await event in group {
//                if let event = event {
//                    Events.append(event)
//                }
//            }
//        }
//
//        print("DEBUG: Cached events = \(Events)")
//        return Events
//    }
//
//    func getEvent(from id: String) async throws -> Event {
//        // Check cache for event
//        if let event: Event = try cache.readCodable(forKey: id) {
//            print("DEBUG: Got event from cache. \(String(describing: event))")
//            return event
//        }
//
//        print("DEBUG: Checking firebase for event ...")
//        // If event not found in cache, fetch from Firebase
//        let snapshot = try await COLLECTION_EVENTS.document(id).getDocument()
//        let event = try snapshot.data(as: Event.self)
//
//        print("DEBUG: Got event from firebase. \(String(describing: event))")
//        // Store in cache
//        let Event = Event(from: event)
//        cacheEvent(Event)
//
//        return Event
//    }
//
//    // Caching Events
//    private func cacheEvents(_ events: [Event]) {
//        for event in events { cacheEvent(event) }
//    }
//
//    func cacheEvent(_ event: Event) {
//        Task {
//            do {
//                guard let id = event.id else { return }
//                try cache.write(codable: event, forKey: id)
//            } catch {
//                print("DEBUG: ❌ Error caching event. \(error.localizedDescription)")
//                return
//            }
//        }
//    }
//
//    // Clearing Cache
//    func clearCache() {
////        cache.cleanDiskCache()
//        cache.cleanAll()
//    }
//
//    func remove(byKey key: String) {
//        cache.clean(byKey: key)
//    }
//}
