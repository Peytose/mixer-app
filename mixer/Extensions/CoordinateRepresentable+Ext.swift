//
//  CoordinateRepresentable+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import CoreLocation

extension CoordinateRepresentable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
