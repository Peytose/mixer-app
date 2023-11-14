//
//  UniversitySearchViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 10/27/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import Combine
import AlgoliaSearchClient

final class UniversitySearchViewModel: ObservableObject {
    @Published var results                      = Set<University>() {
        didSet {
            print("DEBUG: Results: \(results)")
        }
    }
    @Published var searchText: String           = ""
    @Published var isLoading: Bool              = false
    @Published var isShowingSearchResults: Bool = false
    
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
        if !searchText.isEmpty {
            // Start loading
            showLoadingView()
            
            algoliaManager.searchUniversity(from: searchText) { [weak self] result in
                switch result {
                case .success(let response):
                    let universities = response.mapToUniversities()
                    
                    DispatchQueue.main.async {
                        self?.results = Set(universities)
                        self?.hideLoadingView()
                    }
                case .failure(let error):
                    print("DEBUG: Error searching for \(self?.searchText ?? ""): \(error.localizedDescription)")
                    self?.hideLoadingView()
                }
            }
        } else {
            clearInput()
            print("DEBUG: Search text is empty.")
        }
    }
    
    
    func clearInput() {
        self.searchText = ""
        self.results.removeAll()
    }
    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
