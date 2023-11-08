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

struct User: Hashable, Identifiable, Codable {
    // MARK: - Metadata
    @DocumentID var id: String?
    var dateJoined: Timestamp

    // MARK: - Basic Informationr
    var firstName: String
    var lastName: String
    var displayName: String
    let username: String
    let email: String
    var profileImageUrl: String
    var birthday: Timestamp
    var universityId: String
    var gender: Gender

    // MARK: - Additional Information
    var datingStatus: DatingStatus?
    var major: StudentMajor?
    var instagramHandle: String?
    var bio: String?
    var showAgeOnProfile: Bool
    
    // MARK: - Flags and Computed Properties
    var age: Int?
    var relationshipState: RelationshipState?
    var isCurrentUser: Bool {
        return UserService.shared.user?.id == id
    }

    // MARK: - Associated Data
    var hostIdToMemberTypeMap: [String: HostMemberType]?
    var associatedHosts: [Host]?
    var currentHost: Host?
    var university: University?
}

extension User {
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}
