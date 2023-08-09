//
//  GeoPoint+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/6/23.
//

import Firebase
import CoreLocation

extension GeoPoint {
    func toCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
