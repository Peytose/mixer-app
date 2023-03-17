//
//  Event.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import Firebase

enum EventType: String, Codable {
    case school   = "School event"
    case club     = "Club event"
    case party    = "Party"
    case mixer    = "Mixer"
    case rager    = "Rager"
    case darty    = "Darty"
    case kickback = "Kickback"
//    case
    
//    var eventStringPlur: String {
//        switch self {
//            case .school: return "School Events"
//            case .club: return "Club Events"
//            case .houseParty: return "House Parties"
//            case .fratParty: return "Frat Parties"
//            case .mixer: return "Mixers"
//        }
//    }
//
//    var eventStringSing: String {
//        switch self {
//            case .school: return "School event"
//            case .club: return "Club event"
//            case .houseParty: return "House party"
//            case .fratParty: return "Frat party"
//            case .mixer: return "Mixer"
//        }
//    }
}

enum AmenityCategory: String, CaseIterable {
    case keyAmenities       = "Key Amenities"
    case refreshments       = "Refreshments"
    case entertainment      = "Entertainment"
    case furnitureEquipment = "Furniture Equipment"
    case outdoorAreas       = "Outdoor Areas"
    case convenientFeatures = "Convenient Features"
}

enum EventAmenities: String, Codable {
    case alcohol       = "Alcoholic Drinks"
    case nonAlcohol    = "Non-Alcoholic Drinks"
    case beer          = "Beer"
    case water         = "Water"
    case snacks        = "Snacks"
    case food          = "Food"
    case dj            = "DJ"
    case liveMusic     = "Live Music"
    case danceFloor    = "Dance Floor"
    case karaoke       = "Karaoke"
    case videoGames    = "Video Games"
    case indoorGames   = "Indoor Games"
    case outdoorGames  = "Outdoor Games"
    case drinkingGames = "Drinking Games"
    case seating       = "Seating"
    case soundSystem   = "Sound System"
    case projector     = "Projector"
    case lighting      = "Lighting"
    case outdoorSpace  = "Outdoor Space"
    case pool          = "Pool"
    case hotTub        = "Hot Tub"
    case firePit       = "Fire Pit"
    case grillBBQ      = "Grill/BBQ"
    case rooftop       = "Rooftop"
    case garden        = "Garden"
    case security      = "Security"
    case freeParking   = "Free Parking"
    case paidParking   = "Paid Parking"
    case coatCheck     = "Coat Check"
    case bathrooms     = "Bathrooms"
    case smokingArea   = "Smoking Area"
    
    var category: AmenityCategory {
        switch self {
        case .beer, .dj, .danceFloor, .rooftop, .security, .coatCheck, .freeParking, .paidParking: return .keyAmenities
        case .alcohol, .nonAlcohol, .water, .beer, .snacks, .food: return .refreshments
            case .dj, .liveMusic, .danceFloor, .karaoke, .videoGames,
                 .indoorGames, .outdoorGames, .drinkingGames: return .entertainment
            case .seating, .soundSystem, .projector, .lighting: return .furnitureEquipment
            case .outdoorSpace, .pool, .hotTub, .firePit, .grillBBQ, .rooftop, .garden: return .outdoorAreas
            case .security, .freeParking, .paidParking, .coatCheck, .bathrooms, .smokingArea: return .convenientFeatures
        }
    }
    
    var icon: String {
        switch self {
        case .alcohol: return "wineglass.fill"
        case .nonAlcohol: return "cup.and.saucer.fill"
        case .beer: return "mug.fill"
        case .water: return "drop.fill"
        case .snacks: return "carrot.fill"
        case .food: return "fork.knife"
        case .dj: return "music.note.list"
        case .liveMusic: return "music.quarternote.3"
        case .danceFloor: return "figure.socialdance"
        case .karaoke: return "music.mic"
        case .videoGames: return "gamecontroller.fill"
        case .indoorGames: return "figure.cooldown"
        case .outdoorGames: return "figure.basketball"
        case .drinkingGames: return "drop.fill"
        case .seating: return "sofa.fill"
        case .soundSystem: return "hifispeaker.2.fill"
        case .projector: return "videoprojector.fill"
        case .lighting: return "lightbulb.2.fill"
        case .outdoorSpace: return "leaf.fill"
        case .pool: return "figure.pool.swim"
        case .hotTub: return "bathtub.fill"
        case .firePit: return "flame.fill"
        case .grillBBQ: return "cooktop.fill"
        case .rooftop: return "stairs"
        case .garden: return "camera.macro"
        case .security: return "lock.shield"
        case .freeParking, .paidParking: return "parkingsign"
        case .coatCheck: return "tag.fill"
        case .bathrooms: return "toilet.fill"
        case .smokingArea: return "smoke.fill"
        }
    }
}

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    let hostUuid: String
    let hostUsername: String
    let title: String
    let description: String
    let eventImageUrl: String
    let startDate: Timestamp
    var endDate: Timestamp
    let address: String
    let type: EventType
    let isInviteOnly: Bool
    var cost: Float?
    var isFull: Bool?
    var averageRating: Float?
    let amenities: [EventAmenities]
    let tags: [String]
    
    var ageLimit: Int?
    var capacity: Int?
    var attendance: Int?
    var alcoholPresence: Bool?
    
    static func ==(lhs: Event, rhs: CachedEvent) -> Bool {
        // Define how two events are equal
        // For example, you can compare their ids
        return lhs.id == rhs.id
    }
}
