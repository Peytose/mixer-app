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
    static func inviteUser(eventUid: String, uid: String, invitedBy: String, completion: FirestoreCompletion) {
        let data = ["status": GuestStatus.invited.rawValue,
                    "invitedBy": invitedBy,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(uid)
            .updateData(data, completion: completion)
    }
    
    static func checkInUser(eventUid: String, uid: String, checkedInBy: String, completion: FirestoreCompletion) {
        let data = ["status": GuestStatus.checkedIn.rawValue,
                    "checkedInBy": checkedInBy,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(uid).updateData(data, completion: completion)
        
//        Below is commented out to account for future implementation for actual mixer uses
//        { _ in
//            COLLECTION_USERS.document(uid).collection("events-attended").document(eventUid)
//                .setData([:], completion: completion)
//        }
    }
    
    static func addUserToGuestlist(eventUid: String, user: CachedUser, invitedBy: String? = nil, checkedInBy: String? = nil, completion: FirestoreCompletion) {
        guard let userId = user.id else { return }
        
        let guest = EventGuest(from: user, invitedBy: invitedBy, checkedInBy: checkedInBy).toDictionary()
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(userId)
            .setData(guest, completion: completion)
    }
}
