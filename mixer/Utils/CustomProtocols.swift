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

protocol SettingsConfigurable: ObservableObject {
    associatedtype Content: View
    func content(for title: String) -> Binding<String>
    func save(for type: SettingSaveType)
    func saveType(for title: String) -> SettingSaveType
    func toggle(for title: String) -> Binding<Bool>
    func url(for title: String) -> String
    func shouldShowRow(withTitle title: String) -> Bool
    @ViewBuilder func destination(for title: String) -> Content
}

protocol AmenityHandling: ObservableObject {
    var selectedAmenities: Set<EventAmenity> { get set }
    var bathroomCount: Int { get set }
    var containsAlcohol: Bool { get set }
}

