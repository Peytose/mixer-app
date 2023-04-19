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

enum HostPrivileges: String, Codable {
    case basic   = "Basic"
    case premium = "Premium"
}


struct User: Identifiable, Codable {
    // Metadata
    @DocumentID var id: String?
    let dateJoined: Timestamp
    
    // Basic Information
    let username: String
    let email: String
    var profileImageUrl: String
    var name: String
    var birthday: Timestamp
    let university: String
    
    // Additional Information
    var instagramHandle: String?
    var bio: String?
    
    // Host privileges
    var hostPrivileges: [String: HostPrivileges]?
}
