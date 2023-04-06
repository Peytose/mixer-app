//
//  User.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import FirebaseFirestoreSwift
import Firebase

enum UserRelationship: Int, Codable {
    case friends
    case sentRequest
    case receivedRequest
    case notFriends

    var buttonText: String {
        switch self {
            case .friends: return "Friends"
            case .sentRequest: return "Request Sent"
            case .receivedRequest: return "Accept Request"
            case .notFriends: return "Send Request"
        }
    }
    
    var buttonSystemImage: String {
        switch self {
            case .friends: return "person.2.fill"
            case .sentRequest: return "person.wave.2.fill"
            case .receivedRequest: return "person.fill.checkmark"
            case .notFriends: return "person.fill.badge.plus"
        }
    }
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let username: String
    let email: String
    var profileImageUrl: String
    var name: String
    var instaUsername: String
    var birthday: Timestamp
    let university: String
    let dateJoined: Timestamp
    
    var bio: String?
    var relationshiptoUser: UserRelationship?
    var isHost: Bool? = false
    var isSignedUp: Bool? = false
    var isCurrentUser: Bool { return AuthViewModel.shared.userSession?.uid == id }
    var associatedHostAccount: CachedHost?
}
