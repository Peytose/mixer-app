//
//  Host.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import FirebaseFirestore

enum HostType: String, Codable {
    case fraternity     = "Fraternity"
    case sorority       = "Sorority"
    case socialClub     = "Social Club"
    case fraternityCoed = "Fraternity (Co-ed)"
    // Add more cases as needed
    
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
    // Metadata
    @DocumentID var id: String?
    let dateJoined: Timestamp
    
    // Basic Information
    let name: String
    let username: String
    let hostImageUrl: String
    let university: String
    let typesOfEventsHeld: [EventType]
    
    // Additional Information
    var instagramHandle: String?
    var website: String?
    var address: String?
    var bio: String?
    
    // Location
    var geopoint: GeoPoint?
    
    // Members
    var memberUUIDs: [String]
    
    // Host Type
    let hostType: HostType
}
