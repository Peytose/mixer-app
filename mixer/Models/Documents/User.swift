//
//  User.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI

enum AccountType: Int, CustomStringConvertible, Codable {
    case user
    case host
    case member
    
    var description: String {
        switch self {
            case .user: return "User"
            case .host: return "Host"
            case .member: return "Member"
        }
    }
}

struct User: Hashable, Identifiable, Codable {
    // MARK: - Metadata
    @DocumentID var id: String?
    var dateJoined: Timestamp

    // MARK: - Basic Informationr
    var name: String
    var displayName: String
    let username: String
    let email: String
    var profileImageUrl: String
    var birthday: Timestamp
    var universityId: String
    var gender: Gender
    var accountType: AccountType

    // MARK: - Additional Information
    var relationshipStatus: RelationshipStatus?
    var major: StudentMajor?
    var instagramHandle: String?
    var bio: String?
    var showAgeOnProfile: Bool
    
    // MARK: - Flags and Computed Properties
    var age: Int?
    var friendshipState: FriendshipState?
    var isCurrentUser: Bool {
        return UserService.shared.user?.id == id
    }

    // MARK: - Associated Data
    var associatedHostIds: [String]?
    var associatedHosts: [Host]?
    var university: University?
}
