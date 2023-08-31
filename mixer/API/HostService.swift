//
//  HostService.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

class HostService: ObservableObject {
    static let shared = HostService()
    @Published var host: Host?
    
    
    func inviteUser(eventUid: String, uid: String, invitedBy: String, completion: FirestoreCompletion) {
        let data = ["status": GuestStatus.invited.rawValue,
                    "invitedBy": invitedBy,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS
            .document(eventUid)
            .collection("guestlist")
            .document(uid)
            .updateData(data, completion: completion)
    }
    
    
    func checkInUser(eventUid: String, uid: String, completion: FirestoreCompletion) {
        guard let currentUserName = UserService.shared.user?.name else { return }
        
        let data = ["status": GuestStatus.checkedIn.rawValue,
                    "checkedInBy": currentUserName,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS
            .document(eventUid)
            .collection("guestlist")
            .document(uid)
            .updateData(data) { _ in
                COLLECTION_USERS
                    .document(uid)
                    .collection("events-attended")
                    .document(eventUid)
                    .setData(["timestamp": Timestamp()],
                             completion: completion)
            }
    }
    
    
    func addUserToGuestlist(eventUid: String,
                            user: User,
                            status: GuestStatus,
                            invitedBy: String? = nil,
                            checkedInBy: String? = nil,
                            completion: FirestoreCompletion) {
        guard let userId = user.id else { return }
        
        let guest = EventGuest(name: user.name,
                               universityId: user.universityId,
                               email: user.email,
                               username: user.username,
                               profileImageUrl: user.profileImageUrl,
                               age: user.age,
                               gender: user.gender,
                               status: status,
                               invitedBy: invitedBy,
                               checkedInBy: checkedInBy,
                               timestamp: Timestamp())
        
        guard let encodedGuest = try? Firestore.Encoder().encode(guest) else { return }
        
        COLLECTION_EVENTS
            .document(eventUid)
            .collection("guestlist")
            .document(userId)
            .setData(encodedGuest, completion: completion)
    }
    
    
    func removeUserFromGuestlist(with id: String,
                                 eventId: String,
                                 completion: FirestoreCompletion) {
        // Delete the user from the guestlist
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(id)
            .delete { error in
                if let error = error {
                    completion?(error)
                    return
                }
                
                // Delete the notifications
                COLLECTION_NOTIFICATIONS
                
                    .deleteNotifications(forUserID: id,
                                         ofTypes: [.guestlistAdded,
                                                   .guestlistJoined],
                                         eventId: eventId,
                                         completion: completion)
            }
    }
}
