//
//  HostCache.swift
//  mixer
//
//  Created by Peyton Lyons on 2/6/23.
//

import SwiftUI
import FirebaseFirestore
import DataCache
import CryptoKit
import MapKit
import Geohash

class HostCache {
    static let shared = HostCache()
    private init() { configureCache() }
    private let cache = DataCache(name: "HostCache")
    
    enum HostFilterOption {
        case byLocation(location: CLLocationCoordinate2D)
        case all
        // add more cases as needed
        
        func query() -> Query {
            switch self {
            case .byLocation(location: let location):
                let geohash = location.geohash(length: 7)
                return COLLECTION_HOSTS.whereField("geohash", isGreaterThanOrEqualTo: location)
            case .all:
                return COLLECTION_HOSTS
            }
        }
    }
    
    private func configureCache() {
        cache.maxDiskCacheSize = 100 * 1024 * 1024 // 100 MB
        cache.maxCachePeriodInSecond = 30 * 60     // 30 mins
        print("DEBUG: Configured host cache.")
    }
    
    // Cache Key Generation
    private func getKey(for query: Query) -> String {
        let path = query.hash
        return "events-\(path)"
    }
    
    // Fetching hosts
    func fetchHosts(filter: HostFilterOption) async throws -> [CachedHost] {
        let query = filter.query()
        let key = getKey(for: query)
        return try await fetchHosts(for: query, key: key)
    }
    
    private func fetchHosts(for query: Query, key: String) async throws -> [CachedHost] {
        // Check if the cached host ids exist and are not empty
        if let cachedHostIds: [String] = try cache.readCodable(forKey: key), !cachedHostIds.isEmpty {
            return try await getHosts(from: cachedHostIds)
        } else {
            // Fetch documents from Firestore
            let snapshot = try await query.getDocuments()
            let documents = snapshot.documents

            // If documents exist, cache and return the hosts
            if !documents.isEmpty {
                let hosts = documents.compactMap { document -> CachedHost? in
                    do {
                        let host = try document.data(as: Host.self)
                        return CachedHost(from: host)
                    } catch let error {
                        print("Error decoding host: \(error)")
                        return nil
                    }
                }
                
                let hostIds = hosts.map({ $0.id })
                try cache.write(codable: hostIds, forKey: key)
                try await cacheHosts(hosts)
                return hosts
            } else {
                // If no documents exist, return an empty array
                return []
            }
        }
    }

    // Getting hosts
    func getHosts(from hostIds: [String]) async throws -> [CachedHost] {
        var cachedHosts = [CachedHost]()
        for id in hostIds {
            let host = try await getHost(from: id)
            cachedHosts.append(host)
        }
        return cachedHosts
    }

    func getHost(from id: String) async throws -> CachedHost {
        // Check cache for host
        if let host: CachedHost = try cache.readCodable(forKey: id) {
            return host
        }

        // If host not found in cache, fetch from Firebase
        let snapshot = try await COLLECTION_HOSTS.document(id).getDocument()
        let event = try snapshot.data(as: Host.self)

        // Store in cache
        let cachedHost = CachedHost(from: event)
        try cacheHost(cachedHost)

        return cachedHost
    }
    
    // Caching Hosts
    private func cacheHosts(_ hosts: [CachedHost]) async throws {
        for host in hosts { try cacheHost(host) }
    }

    func cacheHost(_ host: CachedHost) throws {
        guard let id = host.id else { return }
        try cache.write(codable: host, forKey: id)
    }
    
    // Clearing Cache
    func clearCache() {
        cache.cleanDiskCache()
    }
}
