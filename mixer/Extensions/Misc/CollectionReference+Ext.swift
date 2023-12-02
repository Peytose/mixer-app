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
                                        using batch: WriteBatch,
                                        completion: @escaping () -> Void) {
        guard let eventId = event.id,
              let activePlannerIds = event.activePlannerIds else {
            return
        }
        
        let group = DispatchGroup()
        
        for userId in activePlannerIds {
            group.enter()
            COLLECTION_NOTIFICATIONS
                .getNotificationDocumentReferences(forUserID: userId,
                                                   ofTypes: types,
                                                   from: currentUserId,
                                                   eventId: eventId) { documentReferences in
                    defer { group.leave() }
                    
                    if let documentReferences = documentReferences {
                        Firestore.addDeleteOperations(to: batch, for: documentReferences)
                    }
                }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }

    
    func getNotificationDocumentReferences(forUserID userID: String,
                                           ofTypes types: [NotificationType],
                                           from uid: String? = nil,
                                           hostId: String? = nil,
                                           eventId: String? = nil,
                                           completion: @escaping ([DocumentReference]?) -> Void) {
        // Build the query
        var query: Query = self.document(userID).collection("user-notifications").whereField("type", in: types.map { $0.rawValue })
        
        // Add filters to the query if provided
        if let uid = uid {
            query = query.whereField("uid", isEqualTo: uid)
        }
        if let hostId = hostId {
            query = query.whereField("hostId", isEqualTo: hostId)
        }
        if let eventId = eventId {
            query = query.whereField("eventId", isEqualTo: eventId)
        }
        
        // Execute the query
        query.getDocuments { snapshot, error in
            if let error = error {
                // Handle the error here, such as logging it or updating some UI
                print("Error fetching notification document references: \(error.localizedDescription)")
                completion(nil) // Complete with nil to indicate failure
                return
            }
            
            let documentReferences = snapshot?.documents.map { $0.reference }
            completion(documentReferences)
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
