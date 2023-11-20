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
    func content(for title: String) -> Binding<String>
    func save(for type: ProfileSaveType)
    func saveType(for title: String) -> ProfileSaveType
    func toggle(for title: String) -> Binding<Bool>
    func url(for title: String) -> String
    func destination(for title: String) -> AnyView
}
