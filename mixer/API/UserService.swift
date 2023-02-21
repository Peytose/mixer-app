//
//  UserService.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import Firebase

typealias FirestoreCompletion = ((Error?) -> Void)?

struct UserService {
    static func joinWaitlist(eventUid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        
        COLLECTION_WAITLISTS.document(eventUid).collection("users").document(currentUid)
            .setData(["timestamp": Timestamp(date: Date())], completion: completion)
    }
    
    
    static func leaveWaitlist(eventUid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        
        COLLECTION_WAITLISTS.document(eventUid).collection("users").document(currentUid)
            .delete(completion: completion)
    }
    
    
    static func fetchQueueNumber(eventUid: String, completion: @escaping (Int?) -> Void) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        
        COLLECTION_WAITLISTS.document(eventUid).collection("users").order(by: "timestamp").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let queueNumber = documents.firstIndex(where: { $0.documentID == currentUid }) ?? -1
            completion(queueNumber)
        }
    }
    
    
    static func sendFriendRequest(uid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"
        let data: [String: Any] = [currentUid: true,
                                          uid: true,
                                     "toUser": uid,
                                   "fromUser": currentUid,
                                    "pending": true,
                                  "timestamp": Timestamp(date: Date())]

        COLLECTION_RELATIONSHIPS.document(path).setData(data, completion: completion)
    }


    static func cancelRequestOrRemoveFriend(uid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"

        COLLECTION_RELATIONSHIPS.document(path).delete(completion: completion)
    }


    static func acceptFriendRequest(uid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"

        COLLECTION_RELATIONSHIPS.document(path).updateData(["pending": false, "timestamp": Timestamp(date: Date())], completion: completion)
    }


    static func getUserRelationship(uid: String, completion: @escaping(UserRelationship) -> Void) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"

        COLLECTION_RELATIONSHIPS.document(path).getDocument { snapshot, _ in
            guard let hasRelationship = snapshot?.exists else { return }
            if !hasRelationship { completion(.notFriends) } else {
                guard let isPending = snapshot?.get("pending") as? Bool else { return }
                if !isPending { completion(.friends) } else {
                    guard let fromUser = snapshot?.get("fromUser") as? String else { return }
                    completion(fromUser == currentUid ? .sentRequest : .receivedRequest)
                }
            }
        }
    }
}
