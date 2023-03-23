//
//  AddressSearchHandler.swift
//  mixer
//
//  Created by Peyton Lyons on 3/17/23.
//

import SwiftUI
import Combine
import MapKit

class AddressSearchHandler: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [MKMapItem] = []
    
    private var searchCancellable: AnyCancellable?
    
    init() {
        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText) in
                self?.searchAddresses(query: searchText)
            }
    }
    
    private func searchAddresses(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.searchResults = response.mapItems
            }
        }
    }
}
