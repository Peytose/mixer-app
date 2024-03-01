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
    
    func approveGuest(with uid: String,
                      for event: Event,
                      by host: Host,
                      completion: FirestoreCompletion) {
        guard let currentUserName = UserService.shared.user?.username,
              let eventId = event.id else { return }
        
        self.inviteUser(eventId: eventId,
                        uid: uid,
                        invitedBy: currentUserName) { error in
            NotificationsViewModel.uploadNotification(toUid: uid,
                                                      type: .guestlistAdded,
                                                      host: host,
                                                      event: event)
            
            completion?(error)
        }
    }
    
    
    func inviteUser(eventId: String,
                    uid: String,
                    invitedBy: String,
                    completion: FirestoreCompletion) {
        let data = ["status": GuestStatus.invited.rawValue,
                    "invitedBy": invitedBy,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(uid)
            .updateData(data, completion: completion)
    }
    
    
    func checkIn(guest: EventGuest,
                 eventId: String,
                 completion: FirestoreCompletion) {
        guard let currentUserName = UserService.shared.user?.username,
              let uid = guest.id else { return }
        
        let data = ["status": GuestStatus.checkedIn.rawValue,
                    "checkedInBy": currentUserName,
                    "timestamp": Timestamp()] as [String: Any]
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(uid)
            .updateData(data) { error in
                if let username = guest.username, !username.isEmpty {
                    COLLECTION_USERS
                        .document(uid)
                        .collection("events-attended")
                        .document(eventId)
                        .setData(["timestamp": Timestamp()],
                                 completion: completion)
                } else {
                    completion?(error)
                }
            }
    }
    
    
    func addUserToGuestlist(eventId: String,
                            user: User,
                            status: GuestStatus,
                            invitedBy: String? = nil,
                            checkedInBy: String? = nil,
                            completion: FirestoreCompletion) {
        guard let userId = user.id else { return }
        
        let guest = EventGuest(name: user.fullName,
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
    
    
    func removeUserFromGuestlist(with id: String, eventId: String, completion: FirestoreCompletion) {
        let batch = Firestore.firestore().batch()
        
        // Reference to the user in the event's guestlist
        let guestlistRef = COLLECTION_EVENTS.document(eventId).collection("guestlist").document(id)
        batch.deleteDocument(guestlistRef)
        
        // Get document references for notifications
        COLLECTION_NOTIFICATIONS.getNotificationDocumentReferences(forUserID: id,
                                                                   ofTypes: [.guestlistAdded, .guestlistJoined],
                                                                   eventId: eventId) { documentReferences in
            if let documentReferences = documentReferences {
                Firestore.addDeleteOperations(to: batch, for: documentReferences)
            }
            batch.commit(completion: completion)
        }
    }
    
    
    func removeMember(from host: Host,
                      memberId: String,
                      completion: FirestoreCompletion) {
        guard let hostId = host.id else { return }
        
        let batch = Firestore.firestore().batch()
        let memberReferenceOnHost = COLLECTION_HOSTS.document(hostId).collection("member-list").document(memberId)
        
        batch.deleteDocument(memberReferenceOnHost)
        
        let updatedUserData: [String: Any] = ["hostIdToMemberTypeMap.\(hostId)": FieldValue.delete()]
        
        let memberReference = COLLECTION_USERS.document(memberId)
        
        batch.updateData(updatedUserData, forDocument: memberReference)
        
        COLLECTION_NOTIFICATIONS
            .getNotificationDocumentReferences(forUserID: host.mainUserId,
                                               ofTypes: [.memberJoined]) { documentReferences in
                if let documentReferences = documentReferences {
                    Firestore.addDeleteOperations(to: batch, for: documentReferences)
                }
                
                batch.commit(completion: completion)
            }
    }
}
