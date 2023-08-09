//
//  MixerLocationAnnotation.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI
import Kingfisher
import ConfettiSwiftUI
import CoreLocation
import MapKit

class MixerLocationAnnotation: NSObject, MKAnnotation {
    let uid: String
    let state: MapSearchType
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var imageUrl: String?
    
    var reuseIdentifier: String {
        switch state {
            case .event: return "event"
            case .host: return "host"
        }
    }
    
    init(location: MixerLocation) {
        self.uid        = location.id ?? ""
        self.state      = location.state
        self.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                 longitude: location.coordinate.longitude)
        self.title      = location.title
        self.imageUrl   = location.imageUrl
    }
}

