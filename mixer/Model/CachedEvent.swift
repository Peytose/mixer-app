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
    var address: String
    var type: EventType
    var isInviteOnly: Bool
    var cost: Float?
    var isFull: Bool?
    var averageRating: Float?
    var amenities: [EventAmenities]
    var tags: [String]
    
    var ageLimit: Int?
    var capacity: Int?
    var attendance: Int?
    var alcoholPresence: Bool?
    var hasStarted: Bool? = false
    var didSave: Bool? = false
    var didAttend: Bool? = false
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    init(from event: Event) {
        self.id              = event.id as String?
        self.hostUuid        = event.hostUuid as String
        self.hostUsername    = event.hostUsername as String
        self.title           = event.title as String
        self.description     = event.description as String
        self.eventImageUrl   = event.eventImageUrl as String
        self.startDate       = event.startDate as Timestamp
        self.endDate         = event.endDate as Timestamp
        self.address         = event.address as String
        self.type            = event.type as EventType
        self.isInviteOnly    = event.isInviteOnly as Bool
        self.cost            = event.cost as Float?
        self.isFull          = event.isFull as Bool?
        self.averageRating   = event.averageRating as Float?
        self.amenities       = event.amenities as [EventAmenities]
        self.tags            = event.tags as [String]
        self.ageLimit        = event.ageLimit as Int?
        self.capacity        = event.capacity as Int?
        self.attendance      = event.attendance as Int?
        self.alcoholPresence = event.alcoholPresence as Bool?
    }
}
