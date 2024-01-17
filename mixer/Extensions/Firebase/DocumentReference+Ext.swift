//
//  DocumentReference+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 1/16/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

extension DocumentReference {
    func fetchWithCachePriority(freshnessDuration: TimeInterval,
                                completion: @escaping (DocumentSnapshot?, Error?) -> Void) {
        // Use a unique identifier for the query, for example, a combination of path and query conditions
        let key = self.path
        
        if TimestampManager.shared.isDataFresh(for: key, freshnessDuration: freshnessDuration) {
            print("DEBUG: Data (\(key)) is fresh, fetching from CACHE ...")
            self.getDocument(source: .cache, completion: completion)
        } else {
            print("DEBUG: Data (\(key)) is NOT fresh, fetching from SERVER ...")
            self.getDocument(source: .server) { snapshot, error in
                if snapshot != nil {
                    TimestampManager.shared.updateTimestamp(for: key)
                }
                completion(snapshot, error)
            }
        }
    }
}
