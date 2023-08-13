//
//  User.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import FirebaseFirestoreSwift
import Firebase

enum AccountType: Int, Codable {
    case user
    case host
    case member
}

struct User: Hashable, Identifiable, Codable {
    // MARK: - Metadata
    @DocumentID var id: String?
    var dateJoined: Timestamp

    // MARK: - Basic Information
    var name: String
    var displayName: String
    let username: String
    let email: String
    var profileImageUrl: String
    var birthday: Timestamp
    var university: String
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
        return AuthViewModel.shared.userSession?.uid == id
    }

    // MARK: - Associated Data
    var associatedHosts: [Host]? = []
}
