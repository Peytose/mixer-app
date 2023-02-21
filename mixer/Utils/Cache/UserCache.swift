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
    
    func fetchUsersFromFirebase() async throws -> [User] {
        let snapshot = try await COLLECTION_USERS.getDocuments()
        let documents = snapshot.documents
        if !documents.isEmpty {
            return documents.compactMap({ try? $0.data(as: User.self) })
        }
        
        return []
    }
}
