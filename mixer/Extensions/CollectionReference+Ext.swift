//
//  CollectionReference+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/27/23.
//

import FirebaseFirestore

extension CollectionReference {
    // Function to update a single document
    func updateDocument(documentID: String,
                        data: [String: Any],
                        completion: FirestoreCompletion) {
        
        let docRef = self.document(documentID)
        docRef.updateData(data) { error in
            completion?(error)
        }
    }
    
    
    func batchUpdate(documentIDs: [String],
                     data: [String: Any],
                     completion: FirestoreCompletion) {
        
        let batch = Firestore.firestore().batch()
        
        for documentID in documentIDs {
            let docRef = self.document(documentID)
            batch.setData(data, forDocument: docRef, merge: true)
        }
        
        batch.commit { error in
            completion?(error)
        }
    }

    
    
    func batchDelete(documentIDs: [String],
                     completion: FirestoreCompletion) {
        let batch = Firestore.firestore().batch()
        
        for documentID in documentIDs {
            let docRef = self.document(documentID)
            batch.deleteDocument(docRef)
        }
        
        batch.commit { error in
            completion?(error)
        }
    }
}

// MARK: - Notification-related
extension CollectionReference {
    func deleteNotificationsForPlanners(for event: Event,
                                        ofTypes types: [NotificationType],
                                        from currentUserId: String,
                                        completion: FirestoreCompletion) {
        guard let eventId = event.id,
              let activePlannerIds = event.activePlannerIds else { return }
        
        for userId in activePlannerIds {
            COLLECTION_NOTIFICATIONS
                .deleteNotifications(forUserID: userId,
                                     ofTypes: types,
                                     from: currentUserId,
                                     eventId: eventId,
                                     completion: completion)
        }
    }

    
    func deleteNotifications(forUserID userID: String,
                             ofTypes types: [NotificationType],
                             from uid: String? = nil,
                             hostId: String? = nil,
                             eventId: String? = nil,
                             completion: FirestoreCompletion) {
        
        // Start building the query
        var query: Query = self.document(userID)
            .collection("user-notifications")
            .whereField("type", in: types.map { $0.rawValue })
        
        // Optionally add the uid filter
        if let uid = uid {
            query = query.whereField("uid", isEqualTo: uid)
        }
        
        // Optionally add the hostId filter
        if let hostId = hostId {
            query = query.whereField("hostId", isEqualTo: hostId)
        }
        
        // Optionally add the eventId filter
        if let eventId = eventId {
            query = query.whereField("eventId", isEqualTo: eventId)
        }
        
        // Execute the query
        query.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Error deleting the documents \(error.localizedDescription)")
                completion?(error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion?(nil)
                return
            }
            
            let documentIDs = documents.map { $0.documentID }
            
            // Batch delete the notifications
            self.document(userID)
                .collection("user-notifications")
                .batchDelete(documentIDs: documentIDs, completion: completion)
        }
    }
    
    
    func updateNotification(forUserID userID: String,
                            notificationID: String,
                            updatedData: [String: Any],
                            completion: FirestoreCompletion) {
        
        // Reference to the specific notification document
        let notificationRef = self.document(userID)
            .collection("user-notifications")
            .document(notificationID)
        
        // Update the data
        notificationRef.updateData(updatedData) { error in
            completion?(error)
        }
    }
}
