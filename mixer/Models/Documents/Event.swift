//
//  Event.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import Firebase

enum CheckInMethod: String, Codable, CaseIterable, IconRepresentable {
    case qrCode   = "QR Code"
    case manual   = "Manual"
    case outOfApp = "Out-of-app"
    
    var icon: String {
        switch self {
        case .qrCode: return "qrcode"
        case .manual: return "pencil.line"
        case .outOfApp: return ""
        }
    }
    
    var description: String {
        switch self {
        case .qrCode:
            return "Guests can use the app to scan a QR code at the event to check in quickly and easily."
        case .manual:
            return "Hosts can manually check in guests by entering their information into a form within the app. This option is useful for guests who don't have the app or can't scan a QR code."
        case .outOfApp:
            return "Hosts can handle check-in outside the app. This option is useful if hosts are using a third-party check-in system or if they prefer to handle check-in manually outside the app."
        }
    }
}

enum EventType: Int, Codable, CaseIterable {
    case school
    case club
    case party
    case mixer
    case rager
    case darty
    case kickback
    
    var text: String {
        switch self {
            case .school: return "School event"
            case .club: return "Club event"
            case .party: return "Party"
            case .mixer: return "Mixer"
            case .rager: return "Rager"
            case .darty: return "Darty"
            case .kickback: return "Kickback"
        }
    }
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
        case .bathrooms, .beer, .water, .dj, .danceFloor: return .keyAmenities
            case .alcohol, .nonAlcohol, .snacks, .food: return .refreshments
            case .liveMusic, .karaoke, .videoGames,
                 .indoorGames, .outdoorGames, .drinkingGames: return .entertainment
            case .seating, .soundSystem, .projector, .lighting: return .furnitureEquipment
            case .outdoorSpace, .pool, .hotTub, .firePit, .grillBBQ, .rooftop, .garden: return .outdoorAreas
            case .security, .freeParking, .paidParking, .coatCheck, .smokingArea: return .convenientFeatures
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


struct Event: Hashable, Identifiable, Codable {
    // MARK: - Metadata
    @DocumentID var id: String?
    var hostId: String
    var hostName: String
    var timePosted: Timestamp
    var eventImageUrl: String

    // MARK: - Basic Information
    var title: String
    var description: String
    var type: EventType
    var note: String?

    // MARK: - Location Information
    var address: String
    var altAddress: String?
    var geoPoint: GeoPoint

    // MARK: - Event Details
    var amenities: [EventAmenities]?
    var checkInMethods: [CheckInMethod]?
    var containsAlcohol: Bool

    // MARK: - Time and Dates
    var startDate: Timestamp
    var endDate: Timestamp
    var registrationDeadlineDate: Timestamp?

    // MARK: - Attendance and Capacity Options
    var guestLimit: Int?
    var guestInviteLimit: Int?
    var memberInviteLimit: Int?

    // MARK: - Event Options
    var isInviteOnly: Bool
    var isManualApprovalEnabled: Bool
    var isGuestlistEnabled: Bool
    var isWaitlistEnabled: Bool

    // MARK: - Payment and Reviews
    var cost: Float?
    var averageRating: Float?

    // MARK: - Flags
    var didGuestlist: Bool? = false
    var didFavorite: Bool?  = false
    var didAttend: Bool?    = false
    var isFull: Bool?       = false
}
