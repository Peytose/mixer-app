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

final class SearchViewModel: ObservableObject {
    @Published var text: String = ""
    private (set) var users     = [CachedUser]()
    @Published var isLoading    = false
    
    
    func executeSearch(for search: String) {
        if !search.isEmpty {
            print("DEBUG: Executing search ...")
            
            COLLECTION_USERS
                .order(by: "username")
                .whereField("username", isGreaterThanOrEqualTo: search)
                .whereField("username", isLessThan: search + "\u{f8ff}")
                .limit(to: 7)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("DEBUG: Error getting users from search. \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    if !documents.isEmpty {
                        print("DEBUG: Found \(documents.count) documents. Returning ...")
                        let results = documents.compactMap({ try? $0.data(as: User.self) }).compactMap { CachedUser(from: $0) }
                        DispatchQueue.main.async {
                            self.users = results
                        }
                    } else {
                        print("DEBUG: Found NO documents for this search!")
                    }
                }
        }
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
