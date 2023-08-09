//
//  Notification.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import FirebaseFirestoreSwift
import Firebase

enum NotificationType: Int, Decodable {
    case requestFriend
    case acceptFriend
    case likedEvent
    case hostFollow
    
    var notificationMessage: String {
        switch self {
            case .requestFriend: return " wants to be friends!"
            case .acceptFriend: return " is now your friend."
            case .likedEvent: return " liked one of your events."
            case .hostFollow: return " started following you!"
        }
    }
}

struct Notification: Identifiable, Decodable {
    @DocumentID var id: String?
    let username: String
    let timestamp: Timestamp
    let profileImageUrl: String
    var type: NotificationType
    let uid: String
    var hasBeenSeen: Bool
    
    var isFollowed: Bool? = false
    var eventId: String?
    var user: User?
}