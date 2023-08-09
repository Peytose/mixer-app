//
//  Friendship.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import FirebaseFirestoreSwift
import Firebase

enum FriendshipState: Int, Codable, IconRepresentable {
    case friends
    case requestSent
    case requestReceived
    case notFriends

    var text: String {
        switch self {
            case .friends: return "Friends"
            case .requestSent: return "Request Sent"
            case .requestReceived: return "Accept Request"
            case .notFriends: return "Send Request"
        }
    }
    
    var icon: String {
        switch self {
            case .friends: return "person.2.fill"
            case .requestSent: return "person.wave.2.fill"
            case .requestReceived: return "person.fill.checkmark"
            case .notFriends: return "person.fill.badge.plus"
        }
    }
}

struct Friendship: Codable {
    let fromUserUid: String
    let toUserUid: String
    let fromUsername: String
    let toUsername: String
    var state: FriendshipState
    var timestamp: Timestamp
}
