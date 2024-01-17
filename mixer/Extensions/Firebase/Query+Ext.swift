//
//  Query+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 1/16/24.
//

import Firebase
import FirebaseFirestore

extension Query {
    func fetchWithCachePriority(queryKey: QueryKey,
                                freshnessDuration: TimeInterval,
                                completion: @escaping (QuerySnapshot?, Error?) -> Void) {
        // Use a unique identifier for the query, for example, a combination of path and query conditions
        let key = queryKey.key
        
        if TimestampManager.shared.isDataFresh(for: key, freshnessDuration: freshnessDuration) {
            print("DEBUG: Data (\(key)) is fresh, fetching from CACHE ...")
            self.getDocuments(source: .cache, completion: completion)
        } else {
            print("DEBUG: Data (\(key)) is NOT fresh, fetching from SERVER ...")
            self.getDocuments(source: .server) { snapshot, error in
                if snapshot != nil {
                    TimestampManager.shared.updateTimestamp(for: key)
                }
                completion(snapshot, error)
            }
        }
    }
}
