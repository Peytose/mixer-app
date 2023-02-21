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
    private var bag = Set<AnyCancellable>()
    private (set) var users = [User]()
    
    public init(dueTime: TimeInterval = 2.0) {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(dueTime), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.executeSearch(for: value)
            })
            .store(in: &bag)
    }
    
    
    func executeSearch(for search: String) {
        if search != "" {
            print("DEBUG: Executing search ...")
            COLLECTION_USERS
                .order(by: "name")
                .whereField("name", isGreaterThanOrEqualTo: search)
                .whereField("name", isLessThan: search + "\u{f8ff}")
                .limit(to: 7)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("DEBUG: Error getting users from search. \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    if !documents.isEmpty {
                        print("DEBUG: Found \(documents.count) documents. Returning ...")
                        let results = documents.compactMap({ try? $0.data(as: User.self) })
                        DispatchQueue.main.async {
                            self.users = results
                        }
                        
                    }
                    
                    print("DEBUG: Found NO documents for this search!")
                }
        }
    }
}

