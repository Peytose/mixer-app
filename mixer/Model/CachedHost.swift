//
//  CachedHost.swift
//  mixer
//
//  Created by Peyton Lyons on 2/7/23.
//

import SwiftUI
import Firebase
import CoreLocation
import Geohash

struct Coordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct CachedHost: Hashable, Identifiable, Codable {
    // Metadata
    var id: String?
    var dateJoined: Timestamp
    var lastUpdated: Date?
    var geohash: String?
    
    // Basic Information
    var name: String
    var username: String
    var hostImageUrl: String
    var university: String
    var typesOfEventsHeld: [EventType]
    
    // Additional Information
    var instagramHandle: String?
    var website: String?
    var address: String?
    var tagline: String?
    var description: String?
    var rating: Float?         = 0.0
    
    // Flags
    var isCurrentHost: Bool?   = false
    var hasCurrentEvent: Bool? = false
    var isFollowed: Bool?      = false
    
    // Location
    var location: Coordinate?
    
    // Members
    var memberUUIDs: [String]
    
    // Host Type
    let hostType: HostType
    
    init(from host: Host) {
        self.id                = host.id
        self.dateJoined        = host.dateJoined
        self.name              = host.name
        self.username          = host.username
        self.hostImageUrl      = host.hostImageUrl
        self.university        = host.university
        self.typesOfEventsHeld = host.typesOfEventsHeld
        self.instagramHandle   = host.instagramHandle
        self.website           = host.website
        self.address           = host.address
        self.tagline           = host.tagline
        self.description       = host.description
        
        if let geopoint = host.geopoint {
            self.location = Coordinate(CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude))
        }
        
        self.memberUUIDs       = host.memberUUIDs
        self.hostType          = host.hostType
    }
}

extension CachedHost {
    func generateGeohash() -> String? {
        guard let _ = address, let latitude = location?.latitude, let longitude = location?.longitude else { return nil }
        return Geohash.encode(latitude: latitude, longitude: longitude, length: 7)
    }
}
