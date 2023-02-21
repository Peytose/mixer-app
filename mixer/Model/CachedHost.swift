//
//  CachedHost.swift
//  mixer
//
//  Created by Peyton Lyons on 2/7/23.
//

import SwiftUI
import CoreLocation

struct CachedHost: Hashable, Identifiable, Codable {
    var id: String?
    var name: String
    var ownerUuid: String
    var username: String
    var hostImageUrl: String
    var university: String
    var typesOfEventsHeld: [EventType]
    
    var instagramHandle: String?
    var website: String?
    var rating: Float? = 0.0
    var address: String?
    var bio: String?
    var isCurrentHost: Bool? = false
    var hasCurrentEvent: Bool? = false
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    // , latitude: CLLocationDegrees?, longitude: CLLocationDegrees?
    init(from host: Host) {
        self.id                = host.id
        self.name              = host.name
        self.ownerUuid         = host.ownerUuid
        self.username          = host.username
        self.hostImageUrl      = host.hostImageUrl
        self.university        = host.university
        self.typesOfEventsHeld = host.typesOfEventsHeld
        
        if let instagramHandle = host.instagramHandle {
            self.instagramHandle = instagramHandle
        }
        
        if let website = host.website {
            self.website = website
        }
        
        if let address = host.address {
            self.address = address
        }
        
        if let bio = host.bio {
            self.bio = bio
        }
    }
}
