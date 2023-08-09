//
//  MixerLocation.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI
import CoreLocation

extension MixerLocation {
    func search(_ text: String) {
        
    }
}
extension MixerLocation: Hashable {
    static func == (lhs: MixerLocation, rhs: MixerLocation) -> Bool {
        lhs.id == rhs.id && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MixerLocation: Identifiable {
    let id: String?
    let title: String
    let subtitle: String
    let imageUrl: String
    let coordinate: CLLocationCoordinate2D
    let state: MapSearchType
    
    init(host: Host) {
        self.id         = host.id
        self.title      = host.name
        self.subtitle   = host.tagline ?? (host.description ?? host.university)
        self.imageUrl   = host.hostImageUrl
        self.coordinate = CLLocationCoordinate2D(latitude: host.location.latitude,longitude: host.location.longitude)
        self.state      = .host
    }
    
    init(event: Event) {
        self.id         = event.id
        self.title      = event.title
        self.subtitle   = String(event.description.prefix(20))
        self.imageUrl   = event.eventImageUrl
        self.coordinate = CLLocationCoordinate2D(latitude: event.geoPoint.latitude,
                                                 longitude: event.geoPoint.longitude)
        self.state      = .event
    }
}
