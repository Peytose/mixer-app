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
    func addBatchUpdate(documentRefsDataMap: [DocumentReference: [String: Any]]) {
        for (docRef, data) in documentRefsDataMap {
            self.setData(data, forDocument: docRef, merge: true)
        }
    }
    
    
    func addBatchDelete(documentRefs: [DocumentReference]) {
        for docRef in documentRefs {
            self.deleteDocument(docRef)
        }
    }
}
