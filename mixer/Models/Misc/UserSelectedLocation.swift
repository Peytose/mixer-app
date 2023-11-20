//
//  UserSelectedLocation.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import CoreLocation

struct UserSelectedLocation: Identifiable, CoordinateRepresentable {
    let id = NSUUID().uuidString
    let title: String
    var coordinate: CLLocationCoordinate2D
}
