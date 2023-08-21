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
    
    var description: String {
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
    var amenities: [EventAmenity]?
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
    var isFavorited: Bool?  = false
    var didAttend: Bool?    = false
    var isFull: Bool?       = false
}
