//
//  Firestore+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 11/6/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

extension Firestore {
    static func addDeleteOperations(to batch: WriteBatch, for documentReferences: [DocumentReference]) {
        for documentReference in documentReferences {
            batch.deleteDocument(documentReference)
        }
    }
    
    
    func queueDeletions(inBatch batch: WriteBatch, forQuery query: Query, completion: @escaping (Error?) -> Void) {
        query.getDocuments { snapshot, error in
            if let error = error  {
                completion(error)
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
        }
    }
}
