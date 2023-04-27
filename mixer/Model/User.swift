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

enum UserOption: String, Codable {
    case showAgeOnProfile = "showAgeOnProfile"
}

enum RelationshipStatus: String, Codable, CaseIterable {
    case single             = "Single"
    case taken              = "Taken"
    case complicated        = "Complicated"
    case preferNotToSay     = "Prefer not to say"
}

enum StudentMajor: String, Codable, CaseIterable {
    case business                        = "Business"
    case health                          = "Health"
    case computerAndInformationSciences  = "Computer and Information Sciences"
    case mathematics                     = "Mathematics"
    case economics                       = "Economics"
    case physics                         = "Physics"
    case socialSciences                  = "Social Sciences and History"
    case politicalScience                = "Political Science"
    case engineering                     = "Engineering"
    case biologicalAndBiomedicalSciences = "Biological and Biomedical Sciences"
    case psychology                      = "Psychology"
    case visualAndPerformingArts         = "Visual and Performing Arts"
    case communicationAndJournalism      = "Communication and Journalism"
    case education                       = "Education"
    case undecided                       = "Undecided"
    case other                           = "Other"
    case preferNotToSay                  = "Prefer not to say"
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
    let universityData: [String: String]
    
    // Additional Information
    var relationshipStatus: RelationshipStatus?
    var major: StudentMajor?
    var userOptions: [String: Bool]
    var instagramHandle: String?
    var bio: String?
    
    // Host privileges
    var hostPrivileges: [String: HostPrivileges]?
}
