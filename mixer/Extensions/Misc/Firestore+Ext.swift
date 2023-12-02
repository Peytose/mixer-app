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
}
