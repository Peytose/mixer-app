//
//  Event.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import Firebase

enum EventType: Int, Decodable {
    case school
    case club
    case houseParty
    case fratParty
    case generalParty
    case mixer
    
    var eventStringPlur: String {
        switch self {
            case .school: return "School Events"
            case .club: return "Club Events"
            case .houseParty: return "House Parties"
            case .fratParty: return "Frat Parties"
            case .generalParty: return "General Parties"
            case .mixer: return "Mixers"
        }
    }
    
    var eventStringSing: String {
        switch self {
            case .school: return "School Event"
            case .club: return "Club Event"
            case .houseParty: return "House Party"
            case .fratParty: return "Frat Party"
            case .generalParty: return "General Party"
            case .mixer: return "Mixer"
        }
    }
}

struct Event: Identifiable, Decodable {
    @DocumentID var id: String?
    let hostUuid: String
    let title: String
    let description: String
    let eventImageUrl: String
    let startDate: Timestamp
    let endDate: Timestamp
    let address: String
    let type: EventType
    let isInviteOnly: Bool
    let cost: Double
    let isCancelled: Bool
    let averageRating: Double
    let amenities: [String]
    let tags: [String]
    var likes: Int
    
    var host: Host?
    var ageLimit: Int?
    var theme: String?
    var attire: String?
    var capacity: Int?
    var attendance: Int?
    var alcoholPresence: Bool?
    var didLike: Bool? = false
    var didAttend: Bool? = false
}
