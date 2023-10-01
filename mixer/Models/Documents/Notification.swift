//
//  Notification.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import FirebaseFirestoreSwift
import FirebaseFirestore
import Firebase

struct Notification: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var hostId: String?
    var eventId: String?
    let uid: String
    let username: String
    let timestamp: Timestamp
    let imageUrl: String
    var type: NotificationType
    
    var isFollowed: Bool? = false
    var isFriends: Bool? = false
    var event: Event?
    var user: User?
    var host: Host?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uid)
        hasher.combine(username)
        // You can add other properties if needed.
    }
}

enum NotificationType: Int, Codable {
    case friendRequest
    case friendAccepted
    case eventLiked
    case newFollower
    case memberInvited
    case memberJoined
    case guestlistJoined
    case guestlistAdded
    
    var notificationMessage: String {
        switch self {
            case .friendRequest: return " sent you a friend request."
            case .friendAccepted: return " is now your friend!"
            case .eventLiked: return " liked "
            case .newFollower: return " started following you!"
            case .memberInvited: return " invited you to join "
            case .memberJoined: return " joined "
            case .guestlistJoined: return " joined the guestlist for "
            case .guestlistAdded: return " added you to the guestlist for "
            
        }
    }
}

