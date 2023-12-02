//
//  CLLocationCoordinate2D+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import CoreLocation

extension CLLocationCoordinate2D: CoordinateRepresentable {
    var coordinate: CLLocationCoordinate2D { self }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
