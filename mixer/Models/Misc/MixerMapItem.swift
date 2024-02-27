//
//  MixerMapItem.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI
import CoreLocation

extension MixerMapItem: Hashable {
    static func == (lhs: MixerMapItem, rhs: MixerMapItem) -> Bool {
        lhs.id == rhs.id && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MixerMapItem: Identifiable {
    let id: String?
    let title: String
    let email: String
    let subtitle: String
    let imageUrl: String
    let coordinate: CLLocationCoordinate2D
    let state: MapItemType
    
    init(host: Host) {
        self.id         = host.id
        self.title      = host.name
        self.email      = host.contactEmail ?? "jose.martinez102001@gmail.com"
        self.subtitle   = host.tagline ?? host.description
        self.imageUrl   = host.hostImageUrl
        self.coordinate = CLLocationCoordinate2D(latitude: host.location.latitude,
                                                 longitude: host.location.longitude)
        self.state      = .host
    }
    
    init(event: Event) {
        self.id         = event.id
        self.title      = event.title
        self.email      = event.title ?? "jose.martinez102001@gmail.com"
        self.subtitle   = String(event.description.prefix(20))
        self.imageUrl   = event.eventImageUrl
        self.coordinate = CLLocationCoordinate2D(latitude: event.geoPoint.latitude,
                                                 longitude: event.geoPoint.longitude)
        self.state      = .event
    }
}
