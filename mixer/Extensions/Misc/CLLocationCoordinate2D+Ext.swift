//
//  CLLocationCoordinate2D+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import CoreLocation
import Firebase

extension CLLocationCoordinate2D: CoordinateRepresentable {
    var coordinate: CLLocationCoordinate2D { self }
    
    func toGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
    
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
