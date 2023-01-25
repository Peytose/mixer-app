//
//  MapViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import MapKit
import CloudKit
import SwiftUI

extension MapView {
    final class LocationMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
        @Published var alertItem: AlertItem?
        @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.35071, longitude: -71.09097),
            latitudinalMeters: LocationMapViewModel.defaultDistance,
            longitudinalMeters: LocationMapViewModel.defaultDistance
        )
        @Published var isLoading = false
        @Published var isShowingHostView = false
        @Published var isShowingAddEventView = false
        @Published var isShowingQRCodeView = false
        @Published var isShowingSearchView = false
        @Published var isShowingFilterView = false
        @Published var isShowingEventUsersListView = false
        @Published var isHost = false
        private let deviceLocationManager = CLLocationManager()
        static let defaultDistance: CLLocationDistance = 1000
        
        @Published var existingProfileRecord: CKRecord?
        
        
        
   
        private func showLoadingView() { isLoading = true }
        private func hideLoadingView() { isLoading = false }
    }
}

