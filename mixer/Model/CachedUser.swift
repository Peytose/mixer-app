//
//  CachedUser.swift
//  mixer
//
//  Created by Peyton Lyons on 3/8/23.
//

import SwiftUI
import Firebase
import CoreLocation

struct CachedUser: Hashable, Identifiable, Codable {
    var id: String?
    var name: String
    var profileImageUrl: String
    var birthday: Timestamp
    var university: String
    var dateJoined: Timestamp
    var bio: String?
    var relationshiptoUser: UserRelationship?
    var isHost: Bool? = false
    var isSignedUp: Bool? = false
    var isCurrentUser: Bool { return AuthViewModel.shared.userSession?.uid == id }
    var associatedHostAccount: CachedHost?
    
    init(from user: User) {
        self.id = user.id
        self.name = user.name
        self.profileImageUrl = user.profileImageUrl
        self.birthday = user.birthday
        self.university = user.university
        self.dateJoined = user.dateJoined
        
        if let bio = user.bio {
            self.bio = bio
        }
        
        if let relationship = user.relationshiptoUser {
            self.relationshiptoUser = relationship
        }
        
        if let isHost = user.isHost {
            self.isHost = isHost
        }
        
        if let isSignedUp = user.isSignedUp {
            self.isSignedUp = isSignedUp
        }
        
        if let associatedHostAccount = user.associatedHostAccount {
            self.associatedHostAccount = associatedHostAccount
        }
    }
}
