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
    enum UserCacheError: Error {
        case invalidUser
    }

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
        let cachedUsers = users.compactMap { CachedUser(from: $0.self) }
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
        try cacheUser(cachedUser)
        
        return cachedUser
    }
    
    
    func getUser(from username: String) async throws -> CachedUser {
        // Check cache for user
        
        // If user not found in cache, fetch from Firebase
        let snapshot = try await COLLECTION_USERS.whereField("username", isEqualTo: username).getDocuments()
        guard let user = try snapshot.documents.first?.data(as: User.self) else {
            throw UserCacheError.invalidUser
        }
        print("DEBUG: getUser() executed. host: \(String(describing: user))")
        // Store in cache
        let cachedUser = CachedUser(from: user)
        try cacheUser(cachedUser)
        
        return cachedUser
    }
    
    
    func clearCache() {
        cache.cleanAll()
    }
    
    
    // Caching users
    private func cacheUsers(_ users: [CachedUser]) async throws {
        for user in users { try cacheUser(user) }
    }

    
    func cacheUser(_ user: CachedUser) throws {
        guard let id = user.id else { return }
        try cache.write(codable: user, forKey: id)
    }
}
