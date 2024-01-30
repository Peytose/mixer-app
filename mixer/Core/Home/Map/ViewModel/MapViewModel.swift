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

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Properties
    @Published var shownMapTypes   = [MapItemType.event, MapItemType.host]
    @Published var mapItems        = [MixerMapItem]() {
        didSet {
            print("DEBUG: Map Items: \(mapItems)")
        }
    }
    @Published var hostEventCounts = [String: Int]()
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var alertItem: AlertItem?
    @Published var isCenteredOnUserLocation = false
    @Published var isShowingLookAround = false
    
    private let hostManager        = HostManager.shared
    private let eventManager       = EventManager.shared
    private var cancellable        = Set<AnyCancellable>()
    
    @Published var route: MKRoute?
    @Published var cameraPostition: MapCameraPosition = .region(.init(center: CLLocationCoordinate2D(latitude: 42.3506934,
                                                                                                     longitude: -71.090978),
                                                           latitudinalMeters: 100,
                                                           longitudinalMeters: 100))
    @Published var userLocation: CLLocationCoordinate2D?


    var lookAroundScene: MKLookAroundScene? {
        didSet {
            if let _ = lookAroundScene {
                isShowingLookAround = true
            }
        }
    }

    let deviceLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        deviceLocationManager.delegate = self
        // Requesting authorization here will result in the `locationManagerDidChangeAuthorization` being called
        if deviceLocationManager.authorizationStatus == .notDetermined {
            deviceLocationManager.requestWhenInUseAuthorization()
        } else {
            // If authorization has already been determined, proceed accordingly without blocking the main thread
            locationManagerDidChangeAuthorization(deviceLocationManager)
        }
        
        // Subscribe to hosts from HostManager
        hostManager.$hosts
            .sink { [weak self] hosts in
                // Update mapItems with hosts
                self?.mapItems = []
                let locations = hosts.compactMap { MixerMapItem(host: $0) }
                self?.mapItems.append(contentsOf: locations)
                
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

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                alertItem = AlertItem(title: Text("Location Services Denied"),
                                      message: Text("Please enable location services in your device settings."),
                                      dismissButton: .default(Text("OK")))
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                manager.requestAlwaysAuthorization()
            case .authorizedAlways:
                manager.startUpdatingLocation()
            @unknown default:
                break
        }
    }
    
    
    func getDirectionsToLocation(with name: String, coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name = name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            print("DEBUG: No location received")
            return
        }
        
        withAnimation(.easeInOut) {
            userLocation = currentLocation.coordinate
            isCenteredOnUserLocation = isMapCentered(on: currentLocation.coordinate)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
        alertItem = AlertItem(title: Text("Location Error"),
                              message: Text("Failed to update the location."),
                              dismissButton: .default(Text("OK")))
    }
    

    func centerMapOnUserLocation() {
        guard let userLocation = self.userLocation else {
            alertItem = AlertItem(title: Text("Location Error"),
                                  message: Text("Unable to find your location."),
                                  dismissButton: .default(Text("OK")))
            return
        }

        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1200, longitudinalMeters: 1200)
        cameraPostition = .region(region)
        isCenteredOnUserLocation = true
    }
    
    
    private func isMapCentered(on coordinate: CLLocationCoordinate2D) -> Bool {
        guard let userLocation = self.userLocation, let region = self.cameraPostition.region else {
            return false
        }

        let tolerance: CLLocationDistance = 50 // meters
        let center = region.center
        let distance = CLLocation(latitude: center.latitude, longitude: center.longitude)
            .distance(from: CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude))

        return distance <= tolerance
    }
    
    
    @MainActor
    func getLookAroundScene(for item: MixerMapItem) {
        Task {
            let request = MKLookAroundSceneRequest(coordinate: item.coordinate)
            lookAroundScene = try? await request.scene
        }
    }

    @MainActor
    func getDirections(to item: MixerMapItem) {
        guard let userLocation = deviceLocationManager.location?.coordinate else { return }
        let destination = item.coordinate

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: userLocation))
        request.destination = MKMapItem(placemark: .init(coordinate: destination))
        request.transportType = .walking

        Task {
            let directions = try? await MKDirections(request: request).calculate()
            route = directions?.routes.first
        }
    }
}
