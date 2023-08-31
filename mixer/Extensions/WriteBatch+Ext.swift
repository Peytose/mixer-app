//
//  WriteBatch+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/30/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

extension WriteBatch {
    func batchUpdate(documentRefs: [DocumentReference],
                     data: [String: Any],
                     completion: FirestoreCompletion) {
        for docRef in documentRefs {
            self.setData(data, forDocument: docRef, merge: true)
        }
        
        self.commit { error in
            completion?(error)
        }
    }

    func batchDelete(documentRefs: [DocumentReference],
                     completion: FirestoreCompletion) {
        for docRef in documentRefs {
            self.deleteDocument(docRef)
        }
        
        self.commit { error in
            completion?(error)
        }
    }
}
