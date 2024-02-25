//
//  CustomProtocols.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import CoreLocation
import SwiftUI

protocol MenuOption {
    var title: String { get }
    var imageName: String { get }
}

protocol CoordinateRepresentable: Equatable {
    var coordinate: CLLocationCoordinate2D { get }
}

protocol AmenityHandling: ObservableObject {
    var selectedAmenities: Set<EventAmenity> { get set }
    var bathroomCount: Int { get set }
    var containsAlcohol: Bool { get set }
}

