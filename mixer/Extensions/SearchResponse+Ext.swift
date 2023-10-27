//
//  SearchResponse+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/20/23.
//

import AlgoliaSearchClient
import SwiftUI

extension SearchResponse {
    func mapToUniversities() -> [University] {
        do {
            let hitsArray: [University] = try self.extractHits()
            return hitsArray
        } catch let error {
            print("DEBUG: Parsing error: \(error)")
            return []
        }
    }
    
    
    func mapToSearchItems() -> [SearchItem] {
        do {
            let hitsArray: [SearchItem] = try self.extractHits()
            return hitsArray
        } catch let error {
            print("DEBUG: Parsing error: \(error)")
            return []
        }
    }
    
    
    func mapToRelationships() -> [Relationship] {
        do {
            let hitsArray: [Relationship] = try self.extractHits()
            return hitsArray
        } catch let error {
            print("DEBUG: Parsing error: \(error)")
            return []
        }
    }
}
