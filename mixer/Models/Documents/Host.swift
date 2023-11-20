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

struct Host: Hashable, Identifiable, Codable, Equatable {
    static func ==(lhs: Host, rhs: Host) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Metadata
    @DocumentID var id: String?
    var mainUserId: String
    let dateJoined: Timestamp

    // MARK: - Basic Information
    var name: String
    let username: String
    var description: String
    var hostImageUrl: String
    let universityId: String

    // MARK: - Host Type & Types of Events Held
    let type: HostType
    var typesOfEvents: [EventType]?

    // MARK: - Additional Information
    var instagramHandle: String?
    var website: String?
    var tagline: String?

    // MARK: - Location
    var address: String?
    var location: GeoPoint
    
    // MARK: - Flags
    var showLocationOnProfile: Bool
    var hasCurrentEvent: Bool?
    var isFollowed: Bool?
    
    // MARK: - Associated Data
    var university: University?
}
