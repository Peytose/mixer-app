//
//  AlgoliaManager.swift
//  mixer
//
//  Created by Peyton Lyons on 8/20/23.
//
import Foundation
import AlgoliaSearchClient

typealias AlgoliaCompletion = (Result<SearchResponse, Error>) -> Void

class AlgoliaManager: ObservableObject {
    private var client: SearchClient
    private var usersIndex: Index
    private var eventsIndex: Index
    private var hostsIndex: Index
    private var relationshipsIndex: Index
    private var universitiesIndex: Index
    static let shared = AlgoliaManager()
    
    init() {
        self.client             = SearchClient(appID: "PM1M1FWXLY",
                                               apiKey: "b8e1ce81d5a8f61beecd12e1a125583d")
        self.usersIndex         = client.index(withName: "prod_users_search")
        self.eventsIndex        = client.index(withName: "prod_events_search")
        self.hostsIndex         = client.index(withName: "prod_hosts_search")
        self.relationshipsIndex = client.index(withName: "prod_relationships_index")
        self.universitiesIndex = client.index(withName: "prod_universities_search")
        
        // Setting attributes for faceting for the relationships index
        let relationshipSettings = Settings()
            .set(\.attributesForFaceting, to: ["initiatorUid",
                                               "recipientUid",
                                               "state"])
        
        self.relationshipsIndex.setSettings(relationshipSettings) { (result) in
            switch result {
            case .success(let response):
                // You can handle a successful settings update here if needed
                print("DEBUG: Settings for relationships index updated successfully. TaskID: \(response.task.taskID)")
            case .failure(let error):
                print("DEBUG: Error setting attributes for faceting: \(error)")
            }
        }
        
        print("DEBUG: init for algolia completed. \(client)")
    }
    
    
    func searchUniversity(from searchText: String, completion: @escaping AlgoliaCompletion) {
        let query = Query(searchText)
        universitiesIndex.search(query: query, completion: completion)
    }
    
    
    func search(by type: SearchType, searchText: String, completion: @escaping AlgoliaCompletion) {
        switch type {
        case .events:
            let query = Query(searchText)
            eventsIndex.search(query: query, completion: completion)
        case .hosts:
            let query = Query(searchText)
            hostsIndex.search(query: query, completion: completion)
        case .users:
            searchBlockedUsers { blockedUserIds in
                print("DEBUG: Blocked users \(blockedUserIds)")
                guard let currentUserId = UserService.shared.user?.id else { return }
                let allExcludedUserIds = blockedUserIds + [currentUserId]
                
                var query = Query(searchText)
                query.filters = allExcludedUserIds.compactMap { "NOT objectID:\($0)" }.joined(separator: " AND ")
                
                self.usersIndex.search(query: query, completion: completion)
            }
        }
    }
    
    
    private func searchBlockedUsers(completion: @escaping ([String]) -> Void) {
        guard let currentUserId = UserService.shared.user?.id else { return }
        guard let currentUsername = UserService.shared.user?.username else { return }
        
        // Structuring the filter as per the provided format
        var query = Query(currentUsername)
        query.filters = "recipientUid:\(currentUserId) AND state:\(RelationshipState.blocked.rawValue)"
        
        relationshipsIndex.search(query: query) { result in
            switch result {
            case .success(let response):
                let relationships: [Relationship] = response.mapToRelationships()
                let blockedUserIds = relationships.compactMap({ $0.initiatorUid })
                completion(blockedUserIds)
            case .failure(let error):
                print("DEBUG: Error searching for blocked relationships: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    
    func validateUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        let query = Query(username)
            .set(\.typoTolerance, to: .false)
            .set(\.queryType, to: .prefixNone)
        
        usersIndex.search(query: query) { result in
            switch result {
            case .success(let response):
                let isUsernameValid = response.hits.isEmpty
                completion(isUsernameValid)
            case .failure(let error):
                print("DEBUG: Error searching for username \(username): \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}

