//
//  SearchViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 2/15/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import Combine
import AlgoliaSearchClient

final class SearchViewModel: ObservableObject {
    @Published var results: [String:[SearchItem]] = [:]
    @Published var searchText: String                   = ""
    @Published var showLocationDetailsCard: Bool        = false
    @Published var isLoading: Bool                      = false
    @Published var selectedSearchType: SearchType       = .users
    @Published var selectedSearchItem: SearchItem?
    
    private let algoliaManager = AlgoliaManager.shared
    private var userService = UserService.shared
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [self] _ in
                performSearch()
            }
            .store(in: &cancellables)
    }
    
    
    func performSearch() {
        if searchText.trimmingAllSpaces().count >= 2 {
            // Start loading
            showLoadingView()
            
            let group = DispatchGroup()
            var hitsCount: [SearchType: Int] = [:]
            
            for type in SearchType.allCases {
                group.enter()
                
                algoliaManager.search(by: type, searchText: searchText) { [weak self] result in
                    switch result {
                    case .success(let response):
                        print("DEBUG: GOT RESPONSE FROM \(type) : \(response.hits.count)")
                        let filteredItems = response.mapToSearchItems()
                        
                        DispatchQueue.main.async {
                            self?.results.updateValue(filteredItems, forKey: type.description)
                            hitsCount[type] = filteredItems.count
                        }
                    case .failure(let error):
                        print("DEBUG: Error searching for \(self?.searchText ?? ""): \(error.localizedDescription)")
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: DispatchQueue.main) { [weak self] in
                self?.hideLoadingView()
                
                if let maxHitsType = hitsCount.max(by: { $0.value < $1.value })?.key {
                    self?.selectedSearchType = maxHitsType
                }
                
                print("DEBUG: Results updated \(self?.results ?? [:])")
            }
        } else {
            print("DEBUG: Search text is empty.")
        }
    }
    
    
    func fetchDetails(for item: SearchItem,
                      completion: @escaping (NavigationState, Event?, Host?, User?) -> Void) {
        guard let objectId = item.objectId else {
            print("DEBUG: ObjectId is nil.")
            return
        }
        
        print("DEBUG: Fetching details for objectId: \(objectId)")
        
        switch selectedSearchType {
        case .events:
            print("DEBUG: Fetching event details.")
            COLLECTION_EVENTS
                .document(objectId)
                .fetchWithCachePriority(freshnessDuration: 1800) { document, error in
                    if let error = error {
                        print("DEBUG: Error fetching event: \(error.localizedDescription)")
                    }
                    
                    if let event = try? document?.data(as: Event.self) {
                        print("DEBUG: Successfully fetched event.")
                        completion(.close, event, nil, nil)
                    } else {
                        print("DEBUG: Failed to decode event.")
                    }
                }
        case .hosts:
            print("DEBUG: Fetching host details.")
            COLLECTION_HOSTS
                .document(objectId)
                .fetchWithCachePriority(freshnessDuration: 3600) { document, error in
                    if let error = error {
                        print("DEBUG: Error fetching host: \(error.localizedDescription)")
                    }
                    
                    if let host = try? document?.data(as: Host.self) {
                        print("DEBUG: Successfully fetched host.")
                        completion(.close, nil, host, nil)
                    } else {
                        print("DEBUG: Failed to decode host.")
                    }
                }
        case .users:
            print("DEBUG: Fetching user details.")
            COLLECTION_USERS
                .document(objectId)
                .fetchWithCachePriority(freshnessDuration: 7200) { document, error in
                    if let error = error {
                        print("DEBUG: Error fetching user: \(error.localizedDescription)")
                    }
                    
                    if let user = try? document?.data(as: User.self) {
                        print("DEBUG: Successfully fetched user.")
                        completion(.close, nil, nil, user)
                    } else {
                        print("DEBUG: Failed to decode user.")
                    }
                }
        }
    }
    
    
    // DEBUG: Func extracted for potential expansion
    func clearInput() {
        self.searchText = ""
        self.results    = [:]
    }
    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
