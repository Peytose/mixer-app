//
//  Event.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import Firebase

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
    var postedByUserId: String
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

extension Event {
    func isEventCurrentlyHappening() -> Bool {
        return self.endDate <= Timestamp() && self.startDate >= Timestamp()
    }
}
