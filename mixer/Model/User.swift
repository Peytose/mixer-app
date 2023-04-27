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

enum RelationshipStatus: String, Codable, CaseIterable, IconRepresentable {
    case focusingOnSelfGrowth        = "Focusing on self-growth"
    case friendsWithStudyBenefits    = "Friends with study benefits"
    case goingThroughABreakup        = "Going through a breakup"
    case swooningOverTheirCrush      = "Swooning over their crush"
    case lookingForLove              = "Looking for love"
    case inALongDistanceRelationship = "In a long-distance relationship"
    case focusingOnTheirPassion      = "Focusing on their passion"
    case keepingItCasual             = "Keeping it casual"
    case waitingForTheRightPerson    = "Waiting for the right person"
    case exploringTheirSexuality     = "Exploring their sexuality"
    case buildingTheirCareer         = "Building their career"
    case embracingTheirIndependence  = "Embracing their independence"
    
    var icon: String {
        switch self {
        case .focusingOnSelfGrowth: return "leaf.arrow.triangle.circlepath"
        case .friendsWithStudyBenefits: return "book.circle.fill"
        case .goingThroughABreakup: return "heart.slash.fill"
        case .swooningOverTheirCrush: return "heart.circle.fill"
        case .lookingForLove: return "heart.fill"
        case .inALongDistanceRelationship: return "airplane.circle.fill"
        case .focusingOnTheirPassion: return "paintpalette.fill"
        case .keepingItCasual: return "person.2.circle.fill"
        case .waitingForTheRightPerson: return "lightbulb.fill"
        case .exploringTheirSexuality: return "figure.stand.line.dotted.figure.stand"
        case .buildingTheirCareer: return "briefcase.fill"
        case .embracingTheirIndependence: return "person.crop.square.fill.and.at.rectangle"
        }
    }
}

enum StudentMajor: String, Codable, CaseIterable, IconRepresentable {
    case computerScience    = "Computer Science"
    case psychology         = "Psychology"
    case biology            = "Biology"
    case business           = "Business"
    case engineering        = "Engineering"
    case economics          = "Economics"
    case communications     = "Communications"
    case politicalScience   = "Political Science"
    case education          = "Education"
    case artHistory         = "Art History"
    case sociology          = "Sociology"
    case mathematics        = "Mathematics"
    case undecided          = "Undecided"
    case notSpecified       = ""
    
    var icon: String {
        switch self {
        case .computerScience: return "desktopcomputer"
        case .psychology: return "brain.head.profile"
        case .biology: return "leaf.fill"
        case .business: return "briefcase.fill"
        case .engineering: return "gearshape.fill"
        case .economics: return "dollarsign.circle.fill"
        case .communications: return "megaphone.fill"
        case .politicalScience: return "person.3.fill"
        case .education: return "person.fill.checkmark"
        case .artHistory: return "paintpalette.fill"
        case .sociology: return "person.2.square.stack.fill"
        case .mathematics: return "function"
        default: return "questionmark.circle.fill"
        }
    }
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
