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
}

enum AmenityCategory: String, CaseIterable {
    case keyAmenities       = "Key Amenities"
    case refreshments       = "Refreshments"
    case entertainment      = "Entertainment"
    case furnitureEquipment = "Furniture Equipment"
    case outdoorAreas       = "Outdoor Areas"
    case convenientFeatures = "Convenient Features"
}

enum EventAmenities: String, Codable, CaseIterable {
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
            case .bathrooms, .beer, .dj, .danceFloor, .rooftop, .coatCheck: return .keyAmenities
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

enum EventOption: String, Codable {
    case containsAlcohol               = "containsAlcohol"
    case isInviteOnly                  = "isInviteOnly"
    case isManualApprovalEnabled       = "isManualApprovalEnabled"
    case isGuestLimitEnabled           = "isGuestLimitEnabled"
    case isWaitlistEnabled             = "isWaitlistEnabled"
    case isMemberInviteLimitEnabled    = "isMemberInviteLimitEnabled"
    case isGuestInviteLimitEnabled     = "isGuestInviteLimitEnabled"
    case isRegistrationDeadlineEnabled = "isRegistrationDeadlineEnabled"
    case isCheckInOptionsEnabled       = "isCheckInOptionsEnabled"
}


struct Event: Identifiable, Codable {
    // Metadata
    @DocumentID var id: String?
    let hostUuid: String
    let hostUsername: String
    let timePosted: Timestamp
    
    // Basic Information
    let title: String
    let description: String
    let eventImageUrl: String
    let type: EventType
    let address: String
    var amenities: [EventAmenities]
    var checkInMethods: [CheckInMethod]?
    
    // Time and Dates
    let startDate: Timestamp
    var endDate: Timestamp
    var registrationDeadlineDate: Timestamp?
    
    // Attendance and Capacity
    var attendance: Int?
    var capacity: Int?
    let guestLimit: String
    let guestInviteLimit: String
    let memberInviteLimit: String
    
    // Event Options
    var eventOptions: [String: Bool]
    
    // Payment and Reviews
    var cost: Float?
    var averageRating: Float?
    
    static func ==(lhs: Event, rhs: CachedEvent) -> Bool {
        // Define how two events are equal
        // For example, you can compare their ids
        return lhs.id == rhs.id
    }
}
