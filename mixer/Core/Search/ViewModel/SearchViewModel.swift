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
        if !searchText.isEmpty {
            // Start loading
            showLoadingView()

            let query = Query(searchText)
            let group = DispatchGroup()
            var hitsCount: [SearchType: Int] = [:]

            for type in SearchType.allCases {
                group.enter()

                algoliaManager.search(by: type, query: query) { [weak self] result in
                    switch result {
                    case .success(let response):
                        let filteredItems = response.mapToSearchItems()
                        DispatchQueue.main.async {
                            self?.results.updateValue(filteredItems, forKey: type.description)
                            print("DEBUG: Items from algolia: \(filteredItems)")
                            
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

    
    
    // DEBUG: Func extracted for potential expansion
    func selectResult(_ item: SearchItem) {
        self.selectedSearchItem = item
    }
    
    
    // DEBUG: Func extracted for potential expansion
    func clearInput() {
        self.searchText = ""
        self.results    = [:]
    }
    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
