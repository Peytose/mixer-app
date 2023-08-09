//
//  Host.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import FirebaseFirestore

enum HostType: Int, Codable {
    case fraternity
    case sorority
    case socialClub
    case fraternityCoed
    // Add more cases as needed
    
    var text: String {
        switch self {
        case .fraternity: return "Fraternity"
        case .sorority: return "Sorority"
        case .socialClub: return "Social Club"
        case .fraternityCoed: return "Fraternity (Co-ed)"
        }
    }
    
    var icon: String {
        switch self {
            case .fraternity: return "house.fill"
            case .sorority: return "person.3.sequence.fill"
            case .socialClub: return "person.2.fill"
            case .fraternityCoed: return "person.2.square.stack.fill"
        }
    }
}

struct Host: Hashable, Identifiable, Codable {
    // MARK: - Metadata
    @DocumentID var id: String?
    var mainUserId: String
    let dateJoined: Timestamp

    // MARK: - Basic Information
    let name: String
    let username: String
    let hostImageUrl: String
    let university: String

    // MARK: - Host Type & Types of Events Held
    let type: HostType
    var typesOfEvents: [EventType]?

    // MARK: - Additional Information
    var instagramHandle: String?
    var website: String?
    var tagline: String?
    var description: String?

    // MARK: - Location
    var address: String?
    var location: GeoPoint

    // MARK: - Members
    var memberIds: [String]?
    
    // MARK: - Flags
    var hasCurrentEvent: Bool? = false
    var isFollowed: Bool?      = false
}
