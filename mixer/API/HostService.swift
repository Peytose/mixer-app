//
//  HostService.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import Firebase

class HostService: ObservableObject {
    static let shared = HostService()
    @Published var host: Host?
    
    
    func approveGuest(with uid: String,
                      for event: Event,
                      by host: Host,
                      completion: FirestoreCompletion) {
        guard let currentUserId = UserService.shared.user?.id,
              let eventId = event.id else { return }
        
        self.inviteUser(eventId: eventId,
                        uid: uid,
                        invitedById: currentUserId) { _ in
            NotificationsViewModel.uploadNotification(toUid: uid,
                                                      type: .guestlistJoined,
                                                      host: host,
                                                      event: event)
        }
    }
    
    
    func inviteUser(eventId: String,
                    uid: String,
                    invitedById: String,
                    completion: FirestoreCompletion) {
        let data = ["status": GuestStatus.invited.rawValue,
                    "invitedBy": invitedById,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(uid)
            .updateData(data, completion: completion)
    }
    
    
    func checkInUser(eventId: String,
                     uid: String,
                     completion: FirestoreCompletion) {
        guard let currentUserName = UserService.shared.user?.name else { return }
        
        let data = ["status": GuestStatus.checkedIn.rawValue,
                    "checkedInBy": currentUserName,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(uid)
            .updateData(data) { _ in
                COLLECTION_USERS
                    .document(uid)
                    .collection("events-attended")
                    .document(eventId)
                    .setData(["timestamp": Timestamp()],
                             completion: completion)
            }
    }
    
    
    func addUserToGuestlist(eventId: String,
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
            .document(eventId)
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
