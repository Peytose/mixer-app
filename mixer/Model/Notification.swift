//
//  Notification.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import FirebaseFirestoreSwift
import Firebase

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
    var user: CachedUser?
}

enum NotificationType: Int, Decodable {
    case requestFriend
    case acceptFriend
    case likedEvent
    
    var notificationMessage: String {
        switch self {
            case .requestFriend: return " wants to be friends!"
            case .acceptFriend: return " accepted your friend request."
            case .likedEvent: return " liked one of your events."
        }
    }
}
