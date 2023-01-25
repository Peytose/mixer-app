//
//  HostService.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

struct HostService {
    static func inviteUser(eventUid: String, uid: String, currentUid: String, completion: FirestoreCompletion) {
        let data = ["status": ListType.invite,
                    "invitedBy": currentUid,
                    "timestamp": Timestamp(date: Date())] as [String: Any]
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(uid)
            .updateData(data, completion: completion)
    }
    
    static func checkInUser(eventUid: String, uid: String, currentUid: String, completion: FirestoreCompletion) {
        let data = ["status": ListType.attend,
                    "checkedInBy": currentUid,
                    "timestamp": Timestamp(date: Date())] as [String: Any]
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(uid).updateData(data) { _ in
            COLLECTION_USERS.document(uid).collection("events-attended").document(eventUid)
                .setData([:], completion: completion)
        }
    }
}
