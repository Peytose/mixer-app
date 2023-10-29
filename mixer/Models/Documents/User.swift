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

enum PrivilegeLevel: Int {
    case basic
    case advanced
    case admin
}

enum HostMemberType: Int, CustomStringConvertible, Codable, CaseIterable {
    case member
    case planner
    case admin
    case moderator
    case vip

    var description: String {
        switch self {
        case .member:
            return "Member"
        case .planner:
            return "Planner"
        case .admin:
            return "Admin"
        case .moderator:
            return "Moderator"
        case .vip:
            return "VIP"
        }
    }
    
    var privilege: PrivilegeLevel {
        switch self {
        case .member:
            return .basic
        case .planner, .vip:
            return .advanced
        case .admin, .moderator:
            return .admin
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
    var hostIdToAccountTypeMap: [String: HostMemberType]?
    var associatedHosts: [Host]?
    var university: University?
}
