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
        let data = ["status": GuestStatus.invited.rawValue,
                    "invitedBy": currentUid,
                    "timestamp": Timestamp(date: Date())] as [String: Any]
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(uid)
            .updateData(data, completion: completion)
    }
    
    static func checkInUser(eventUid: String, uid: String, currentUserName: String, completion: FirestoreCompletion) {
        let data = ["status": GuestStatus.checkedIn.rawValue,
                    "checkedInBy": currentUserName,
                    "timestamp": Timestamp(date: Date())] as [String: Any]
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(uid).updateData(data, completion: completion)
        
//        Below is commented out to account for future implementation for actual mixer uses
//        { _ in
//            COLLECTION_USERS.document(uid).collection("events-attended").document(eventUid)
//                .setData([:], completion: completion)
//        }
    }
}
