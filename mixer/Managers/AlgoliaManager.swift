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
    static let shared = AlgoliaManager()
    // Add other indexes as needed
    
    init() {
        self.client      = SearchClient(appID: "PM1M1FWXLY",
                                        apiKey: "c9219b0edb6cf85f8cf5726851e20882")
        self.usersIndex  = client.index(withName: "prod_users_search")
        self.eventsIndex = client.index(withName: "prod_events_search")
        self.hostsIndex  = client.index(withName: "prod_hosts_search")
        
        print("DEBUG: init for algolia completed. \(client)")
    }
    
    
    func search(by type: SearchType, query: Query, completion: @escaping AlgoliaCompletion) {
        switch type {
            case .events:
                eventsIndex.search(query: query, completion: completion)
            case .hosts:
                hostsIndex.search(query: query, completion: completion)
            case .users:
                usersIndex.search(query: query, completion: completion)
        }
    }
    
    
    func validateUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        var query = Query(username)
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

