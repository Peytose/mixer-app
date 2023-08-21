//
//  SearchResponse+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/20/23.
//

import AlgoliaSearchClient
import SwiftUI

extension SearchResponse {
    func mapToSearchItems() -> [SearchItem] {
        do {
            let hitsArray: [SearchItem] = try self.extractHits()
            return hitsArray
        } catch let error {
            print("DEBUG: Parsing error: \(error)")
            return []
        }
    }
}
