////
////  Event.swift
////  mixer
////
////  Created by Peyton Lyons on 2/8/23.
////
//
//import FirebaseFirestoreSwift
//import Firebase
//import CoreLocation
//
//struct Event: Hashable, Identifiable, Codable {
//    // Metadata
//    var id: String?
//    var hostId: String
//    var hostName: String
//    let timePosted: Timestamp
//    
//    // Basic Information
//    var title: String
//    var description: String
//    var eventImageUrl: String
//    var type: EventType
//    var address: String
//    var amenities: [EventAmenity]?
//    var notes: String?
//    var altAddress: String?
//    var checkInMethods: [CheckInMethod]?
//    
//    // Time and Dates
//    var startDate: Timestamp
//    var endDate: Timestamp
//    var cutOffDate: Timestamp?
//    
//    // Attendance and Capacity
//    var attendance: Int?
//    var capacity: Int?
//    var isFull: Bool?
//    var guestLimit: String
//    var guestInviteLimit: String
//    var memberInviteLimit: String
//    
//    // Event Options
//    var eventOptions: [String: Bool]
//    var hasStarted: Bool?
//    
//    // Payment and Reviews
//    var cost: Float?
//    var averageRating: Float?
//    
//    // Location
//    var latitude: CLLocationDegrees?
//    var longitude: CLLocationDegrees?
//    
//    // Flags
//    var didGuestlist: Bool? = false
//    var didLike: Bool?      = false
//    var didAttend: Bool?    = false
//    var saves: Int?         = 0
//    
//    init(from event: Event) {
//        self.id                            = event.id
//        self.hostId                      = event.hostId
//        self.hostName                      = event.hostName
//        self.timePosted                    = event.timePosted
//        self.title                         = event.title
//        self.description                   = event.description
//        self.eventImageUrl                 = event.eventImageUrl
//        self.type                          = event.type
//        self.address                       = event.address
//        self.startDate                     = event.startDate
//        self.endDate                       = event.endDate
//        self.cutOffDate      = event.cutOffDate
//        self.attendance                    = event.attendance
//        self.capacity                      = event.capacity
//        self.guestLimit                    = event.guestLimit
//        self.guestInviteLimit              = event.guestInviteLimit
//        self.memberInviteLimit             = event.memberInviteLimit
//        self.eventOptions                  = event.eventOptions
//        self.amenities                     = event.amenities
//        self.notes                         = event.notes
//        self.altAddress                 = event.altAddress
//        self.checkInMethods                = event.checkInMethods
//        self.cost                          = event.cost
//        self.averageRating                 = event.averageRating
//    }
//}
