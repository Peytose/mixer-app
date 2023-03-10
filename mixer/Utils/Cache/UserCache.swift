//
//  UserCache.swift
//  mixer
//
//  Created by Peyton Lyons on 2/15/23.
//

import SwiftUI
import FirebaseFirestore
import DataCache
import CryptoKit

class UserCache {
    static let shared = UserCache()
    private init() { configureCache() }
    private let cache = DataCache(name: "UserCache")
    private let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    
    private func configureCache() {
        cache.maxDiskCacheSize = 100 * 1024 * 1024    // 100 MB
        cache.maxCachePeriodInSecond = 60 * 60        // 60 mins
    }
    
    
    func fetchUsers() async throws -> [CachedUser] {
        print("DEBUG: Started fetching hosts!")
        let query = COLLECTION_USERS
        
        // Check cache for users
        if let users: [CachedUser] = try cache.readCodable(forKey: "users") {
            if !users.isEmpty {
                print("DEBUG: Found users in cache! Fetching ... \(users)")
                return users
            }
        }
        
        print("DEBUG: Could not find in cache. Checking Firebase...")
        // If users not found in cache, fetch and cache from Firebase
        return try await fetchAndCache(for: query)
    }
    
    
    func fetchAndCache(for query: Query) async throws -> [CachedUser] {
        let snapshot = try await query.getDocuments()
        let documents = snapshot.documents
        let users = documents.compactMap({ try? $0.data(as: User.self) })
        print("DEBUG: Found user(s) on Firebase! \(users)")
        // Store in cache
        var cachedUsers = users.compactMap { CachedUser(from: $0.self) }
        print("DEBUG: Users from firebase for cache: \(cachedUsers)")
        
        try cache.write(codable: cachedUsers, forKey: "users")
        try await cacheUsers(cachedUsers)
        
        return cachedUsers
    }
    
    
    func getUser(withId id: String) async throws -> CachedUser {
        // Check cache for user
        if let user: CachedUser = try cache.readCodable(forKey: id) {
            return user
        }
        
        // If user not found in cache, fetch from Firebase
        let snapshot = try await COLLECTION_USERS.document(id).getDocument()
        let user = try snapshot.data(as: User.self)
        print("DEBUG: getUser() executed. host: \(user)")
        // Store in cache
        let cachedUser = CachedUser(from: user)
        try await cacheUser(cachedUser)
        
        return cachedUser
    }
    
    
    func clearCache() {
        cache.cleanAll()
    }
    
    
    private func cacheUsers(_ users: [CachedUser]) async throws {
        for user in users {
            try await cacheUser(user)
        }
    }
    
    
    func cacheUser(_ user: CachedUser) async throws {
        print("DEBUG: Caching ...")
        guard let id = user.id else { return }
        cache.clean(byKey: id)
        try cache.write(codable: user, forKey: id)
        if let users: [CachedUser] = try cache.readCodable(forKey: "users") {
            var cachedUsers = users.compactMap({ $0.self })
            print("DEBUG: Cached users in cacheUser() : \(cachedUsers)")
            if !cachedUsers.isEmpty {
                if let existingUserIndex = cachedUsers.firstIndex(where: { $0.id == user.id }) {
                    cachedUsers.remove(at: existingUserIndex)
                    cachedUsers.append(user)
                    cache.clean(byKey: "users")
                    try cache.write(codable: cachedUsers, forKey: "hosts")
                    print("DEBUG: Replaced user in user cache!")
                }
            }
        }
        print("DEBUG: User Cached! id: \(id)")
    }
}
