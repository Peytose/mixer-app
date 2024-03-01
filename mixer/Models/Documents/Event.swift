//
//  Event.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Event: Hashable, Identifiable, Codable, Equatable {
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Metadata
    @DocumentID var id: String?
    var hostIds: [String]
    var hostNames: [String]
    var plannerHostStatusMap: [String: PlannerStatus]
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
    var bathroomCount: Int?
    var isCheckInViaMixer: Bool
    var containsAlcohol: Bool

    // MARK: - Time and Dates
    var startDate: Timestamp
    var endDate: Timestamp
    var cutOffDate: Timestamp?

    // MARK: - Attendance and Capacity Options
    var guestLimit: Int?
    var memberInviteLimit: Int?

    // MARK: - Event Options
    var isPrivate: Bool
    var isInviteOnly: Bool
    var isManualApprovalEnabled: Bool

    // MARK: - Payment and Reviews
    var cost: Float?
    var averageRating: Float?

    // MARK: - Flags
    var didGuestlist: Bool?
    var didRequest: Bool?
    var isFavorited: Bool?
    var didAttend: Bool?
    var isFull: Bool? = false
}

extension Event {
    var isCurrent: Bool {
        let now = Date()
        let startDateAsDate = self.startDate.dateValue()
        let endDateAsDate = self.endDate.dateValue()
        return startDateAsDate <= now && endDateAsDate >= now
    }
    
    var isToday: Bool {
        let calendar = Calendar.current
        let now = Date()
        let startDateAsDate = self.startDate.dateValue()
        return calendar.isDate(startDateAsDate, inSameDayAs: now)
    }
    
    var isPast: Bool {
        let now = Date()
        let endDateAsDate = self.endDate.dateValue()
        return endDateAsDate < now
    }

    var isFuture: Bool {
        let now = Date()
        let startDateAsDate = self.startDate.dateValue()
        return startDateAsDate > now
    }
}
