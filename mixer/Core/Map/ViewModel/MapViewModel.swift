//
//  MapViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine
import MapKit

class MapViewModel: ObservableObject {
    // MARK: - Properties
    @Published var shownMapTypes   = [MapItemType.event, MapItemType.host]
    @Published var mapItems        = Set<MixerMapItem>()
    @Published var hostEventCounts = [String: Int]()
    @Published var selectedMixerMapItem: MixerMapItem?
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var alertItem: AlertItem?
    
    private let hostManager        = HostManager.shared
    private let eventManager       = EventManager.shared
    private var cancellable        = Set<AnyCancellable>()
    
    var userLocation: CLLocationCoordinate2D?
    
    init() {
        // Subscribe to hosts from HostManager
        hostManager.$hosts
            .sink { [weak self] hosts in
                // Update mapItems with hosts
                let locations = hosts.compactMap { MixerMapItem(host: $0) }
                self?.mapItems.formUnion(locations)
                
                // Reset and calculate event counts for each host
                self?.hostEventCounts = [:]
                hosts.forEach { host in
                    guard let hostId = host.id else { return }
                    let eventCount = self?.countEventsForHost(hostId: hostId) ?? 0
                    self?.hostEventCounts[hostId] = eventCount
                }
            }
            .store(in: &cancellable)
    }
    
    
    private func countEventsForHost(hostId: String) -> Int {
        return eventManager.events.filter { $0.hostIds.contains(hostId) }.count
    }
}

//extension MapView {
//    
//    @Observable
//    final class MapViewModel: NSObject, CLLocationManagerDelegate {
//        var isShowingDetailView = false
//        var isShowingLookAround = false
//        var alertItem: AlertItem?
//        var route: MKRoute?
//
//        var cameraPostition: MapCameraPosition = .region(.init(center: CLLocationCoordinate2D(latitude: 37.331516,
//                                                                                              longitude: -121.891054),
//                                                               latitudinalMeters: 1200,
//                                                               longitudinalMeters: 1200))
//
//        var lookAroundScene: MKLookAroundScene? {
//            didSet {
//                if let _ = lookAroundScene {
//                    isShowingLookAround = true
//                }
//            }
//        }
//
//        let deviceLocationManager = CLLocationManager()
//        
//        override init() {
//            super.init()
//            deviceLocationManager.delegate = self
//        }
//        
//        func requestAllowOnceLocationPermission() {
//            deviceLocationManager.requestLocation()
//        }
//        
//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            guard let currentLocation = locations.last else { return }
//            
//            withAnimation {
//                cameraPostition = .region(.init(center: currentLocation.coordinate,
//                                                latitudinalMeters: 1200, longitudinalMeters: 1200))
//            }
//        }
//        
//        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//            print("Did Fail With Error")
//        }
//        
//        @MainActor
//        func getLocations(for locationManager: LocationManager) {
//            Task {
//                do {
//                    locationManager.locations = try await CloudKitManager.shared.getLocations()
//                } catch {
//                    alertItem = AlertContext.unableToGetLocations
//                }
//            }
//        }
//        
//        @MainActor
//        func getCheckedInCounts() {
//            Task {
//                do {
//                    checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfilesCount()
//                } catch {
//                    alertItem = AlertContext.checkedInCount
//                }
//            }
//        }
//        
//        @MainActor
//        @ViewBuilder func createLocationDetailView(for location: DDGLocation, in dynamicTypeSize: DynamicTypeSize) -> some View {
//            if dynamicTypeSize >= .accessibility3 {
//                LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
//            } else {
//                LocationDetailView(viewModel: LocationDetailViewModel(location: location))
//            }
//        }
//
//        @MainActor
//        func getLookAroundScene(for location: DDGLocation) {
//            Task {
//                let request = MKLookAroundSceneRequest(coordinate: location.location.coordinate)
//                lookAroundScene = try? await request.scene
//            }
//        }
//
//        @MainActor
//        func getDirections(to location: DDGLocation) {
//            guard let userLocation = deviceLocationManager.location?.coordinate else { return }
//            let destination = location.location.coordinate
//
//            let request = MKDirections.Request()
//            request.source = MKMapItem(placemark: .init(coordinate: userLocation))
//            request.destination = MKMapItem(placemark: .init(coordinate: destination))
//            request.transportType = .walking
//
//            Task {
//                let directions = try? await MKDirections(request: request).calculate()
//                route = directions?.routes.first
//            }
//        }
//    }
//}





















