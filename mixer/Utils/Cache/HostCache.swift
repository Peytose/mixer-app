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

class HostCache {
    static let shared = HostCache()
    private init() { configureCache() }
    private let cache = DataCache(name: "HostCache")
    
    private func configureCache() {
        cache.maxDiskCacheSize = 100 * 1024 * 1024    // 100 MB
        cache.maxCachePeriodInSecond = 30 * 60        // 30 mins
        print("DEBUG: Configured host cache.")
    }
    
    
    func fetchHosts() async throws -> [CachedHost] {
        print("DEBUG: Started fetching hosts!")
        let query = COLLECTION_HOSTS
        
        // Check cache for hosts
        if let hosts: [CachedHost] = try cache.readCodable(forKey: "hosts") {
            if !hosts.isEmpty {
                print("DEBUG: Found hosts in cache! Fetching ... \(hosts)")
                return hosts
            }
        }
        
        print("DEBUG: Could not find in cache. Checking Firebase...")
        // If hosts not found in cache, fetch and cache from Firebase
        return try await fetchAndCache(for: query)
    }
    
    
    func fetchAndCache(for query: Query) async throws -> [CachedHost] {
        let snapshot = try await query.getDocuments()
        let documents = snapshot.documents
        let hosts = documents.compactMap({ try? $0.data(as: Host.self) })
        print("DEBUG: Found hosts on Firebase! \(hosts)")
        // Store in cache
        var cachedHosts = hosts.compactMap { CachedHost(from: $0.self) }
        print("DEBUG: Hosts from firebase for cache: \(cachedHosts)")
        
        for var host in cachedHosts {
            if let address = host.address {
                if let coordinates = try await address.coordinates() {
                    host.latitude = coordinates.latitude
                    host.longitude = coordinates.longitude
                    
                    print("DEBUG: Host coords input!")
                    print("DEBUG: lat  : \(String(describing: host.latitude))")
                    print("DEBUG: long : \(String(describing: host.longitude))")
                    
                    if let existingHostIndex = cachedHosts.firstIndex(where: { $0.id == host.id }) {
                        cachedHosts.remove(at: existingHostIndex)
                        cachedHosts.append(host)
                    }
                }
            }
        }
        
        try cache.write(codable: cachedHosts, forKey: "hosts")
        try await cacheHosts(cachedHosts)
        
        return cachedHosts
    }
    
    
    func getHost(withId id: String) async throws -> CachedHost {
        // Check cache for host
        if let host: CachedHost = try cache.readCodable(forKey: id) {
            return host
        }
        
        // If host not found in cache, fetch from Firebase
        let snapshot = try await COLLECTION_HOSTS.document(id).getDocument()
        let host = try snapshot.data(as: Host.self)
        print("DEBUG: getHost() executed. host: \(host)")
        // Store in cache
        let cachedHost = CachedHost(from: host)
        try await cacheHost(cachedHost)
        
        return cachedHost
    }
    
    
    func clearCache() {
        cache.cleanAll()
    }
    
    
    private func cacheHosts(_ hosts: [CachedHost]) async throws {
        for host in hosts {
            try await cacheHost(host)
        }
    }
    
    
    func cacheHost(_ host: CachedHost) async throws {
        print("DEBUG: Caching ...")
        guard let id = host.id else { return }
        cache.clean(byKey: id)
        try cache.write(codable: host, forKey: id)
        if let hosts: [CachedHost] = try cache.readCodable(forKey: "hosts") {
            var cachedHosts = hosts.compactMap({ $0.self })
            print("DEBUG: Cached hosts in cacheHost() : \(cachedHosts)")
            if !cachedHosts.isEmpty {
                if let existingHostIndex = cachedHosts.firstIndex(where: { $0.id == host.id }) {
                    cachedHosts.remove(at: existingHostIndex)
                    cachedHosts.append(host)
                    cache.clean(byKey: "hosts")
                    try cache.write(codable: cachedHosts, forKey: "hosts")
                    print("DEBUG: Replaced host in host cache!")
                }
            }
        }
        print("DEBUG: Host Cached! id: \(id)")
    }
}
