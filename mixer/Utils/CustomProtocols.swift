//
//  CustomProtocols.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import Foundation
import CoreLocation

protocol MenuOption {
    var title: String { get }
    var imageName: String { get }
}

protocol CoordinateRepresentable: Equatable {
    var coordinate: CLLocationCoordinate2D { get }
}
