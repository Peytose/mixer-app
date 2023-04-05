//
//  CachedEvent.swift
//  mixer
//
//  Created by Peyton Lyons on 2/8/23.
//

import FirebaseFirestoreSwift
import Firebase
import CoreLocation

struct CachedEvent: Hashable, Identifiable, Codable {
    var id: String?
    var hostUuid: String
    var hostUsername: String
    var title: String
    var description: String
    var eventImageUrl: String
    var startDate: Timestamp
    var endDate: Timestamp
    var registrationDeadlineDate: Timestamp

    var address: String
    var type: EventType
    var isInviteOnly: Bool
    
    var cost: Float?
    var isFull: Bool?//
    var averageRating: Float?
    var amenities: [EventAmenities]//
    
    var guestLimit: String
    var guestInviteLimit: String
    var memberInviteLimit: String
    var privacy: CreateEventViewModel.PrivacyType
    var selectedAmenities: [EventAmenities]
    var alcoholPresence: Bool
    var isManualApprovalEnabled: Bool
    var isGuestLimitEnabled: Bool
    var isWaitlistEnabled: Bool
    var isMemberInviteLimitEnabled: Bool
    var isGuestInviteLimitEnabled: Bool
    var isRegistrationDeadlineEnabled: Bool
    var isCheckInOptionsEnabled: Bool
    
    var capacity: Int?//
    var attendance: Int?
    var hasStarted: Bool? = false
    var didSave: Bool? = false
    var didAttend: Bool? = false
    var saves: Int? = 0
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    let timePosted: Timestamp
    var checkInMethod: CreateEventViewModel.CheckInMethod?
    
    init(from event: Event) {
        self.id = event.id as? String
        self.hostUuid = event.hostUuid as String
        self.hostUsername = event.hostUsername as String
        self.title = event.title as String
        self.description = event.description as String
        self.eventImageUrl = event.eventImageUrl as String
        self.startDate = event.startDate as Timestamp
        self.endDate = event.endDate as Timestamp
        self.registrationDeadlineDate = event.registrationDeadlineDate as Timestamp
        self.address = event.address as String
        self.type = event.type as EventType
        self.isInviteOnly = event.isInviteOnly as Bool
        self.cost = event.cost as Float?
        self.isFull = event.isFull as Bool?
        self.averageRating = event.averageRating as Float?
        self.amenities = event.amenities as [EventAmenities]
        self.guestLimit = "0"
        self.guestInviteLimit = "0"
        self.memberInviteLimit = "0"
        self.privacy = event.privacy as CreateEventViewModel.PrivacyType
        self.selectedAmenities = []
        self.alcoholPresence = false
        self.isManualApprovalEnabled = false
        self.isGuestLimitEnabled = false
        self.isWaitlistEnabled = false
        self.isMemberInviteLimitEnabled = false
        self.isGuestInviteLimitEnabled = false
        self.isRegistrationDeadlineEnabled = false
        self.isCheckInOptionsEnabled = false
        self.capacity = event.capacity as Int?
        self.attendance = event.attendance as Int?
        self.hasStarted = false
        self.didSave = false
        self.didAttend = false
        self.saves = 0
        self.latitude = nil
        self.longitude = nil
        self.timePosted = event.timePosted as Timestamp
        self.checkInMethod = nil
    }
}

