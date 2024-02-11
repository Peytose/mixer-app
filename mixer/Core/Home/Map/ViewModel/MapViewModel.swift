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

struct TransportType: Hashable {
    let type: MKDirectionsTransportType

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(type.rawValue)
    }

    static func == (lhs: TransportType, rhs: TransportType) -> Bool {
        lhs.type == rhs.type
    }
}


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
    @Published var travelTimes: [TransportType: TimeInterval] = [:]

    private let hostManager        = HostManager.shared
    private let eventManager       = EventManager.shared
    private var cancellable        = Set<AnyCancellable>()
    
    @Published var route: MKRoute?
//    @Published var cameraPostition: MapCameraPosition = .region(.init(center: CLLocationCoordinate2D(latitude: 42.3506934,
//                                                                                                     longitude: -),
//                                                                      latitudinalMeters: 100,
//                                                                      longitudinalMeters: 100))
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3506934, longitude: -71.090978),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Zoomed in enough to see the city
    ))
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
        
        checkLocationAuthorizationStatus()
        
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
    
    private func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                // Keep default region or ask for permission
                break
            case .authorizedWhenInUse, .authorizedAlways:
                // Optionally, if you already have permission, you can immediately start location updates
                deviceLocationManager.startUpdatingLocation()
            @unknown default:
                break
        }
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
    
    
    func getDirectionsToLocation(title: String, coordinate: CLLocationCoordinate2D, mode: String) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: mode]
        mapItem.openInMaps(launchOptions: launchOptions)
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
    
    func calculateTravelTime(to destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType, completion: @escaping (TimeInterval?, Error?) -> Void) {
        guard let userLocation = self.userLocation else {
            completion(nil, CustomError.locationUnavailable)
            return
        }

        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = transportType

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                if let route = response?.routes.first {
                    print("\(transportType): From \(userLocation.latitude),\(userLocation.longitude) to \(destination.latitude),\(destination.longitude) - Time: \(route.expectedTravelTime)")
                    completion(route.expectedTravelTime, nil)
                } else {
                    completion(nil, CustomError.routeNotFound)
                }
            }
        }
    }

    
    func calculateTravelTimes(to destination: CLLocationCoordinate2D) {
        // Clear previous values
        travelTimes = [:]

        // Calculate travel time for each transport type
        let transportTypes: [MKDirectionsTransportType] = [.walking, .automobile, .transit]
        for transportType in transportTypes {
            calculateTravelTime(to: destination, transportType: transportType) { [weak self] (time, error) in
                DispatchQueue.main.async {
                    if let time = time {
                        // On the main thread, store the travel time for the transport type
                        self?.travelTimes[TransportType(type: transportType)] = time
                    } else if let error = error {
                        // Handle the error, perhaps by showing an alert or logging
                        print("Error calculating \(transportType) travel time: \(error.localizedDescription)")
                    }
                }
            }
        }
    }


    enum CustomError: Error {
        case locationUnavailable
        case routeNotFound

        var errorDescription: String? {
            switch self {
            case .locationUnavailable:
                return "User location is unavailable."
            case .routeNotFound:
                return "No route was found."
            }
        }
    }
    
    func centerMapOnUserLocation() {
        guard let userLocation = self.userLocation else {
            alertItem = AlertItem(title: Text("Location Error"),
                                  message: Text("Unable to find your location."),
                                  dismissButton: .default(Text("OK")))
            return
        }
        
        // Define the new region to center the map on the user's location with animation
        let newRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1200, longitudinalMeters: 1200)
        
        // Use SwiftUI's withAnimation to smoothly transition to the new region
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.cameraPosition = .region(newRegion)
                self.isCenteredOnUserLocation = true
            }
        }
    }
    
    
    
    private func isMapCentered(on coordinate: CLLocationCoordinate2D) -> Bool {
        guard let userLocation = self.userLocation, let region = self.cameraPosition.region else {
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
