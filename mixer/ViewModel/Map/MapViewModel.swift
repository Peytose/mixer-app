//
//  MapViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 2/4/23.
//

import SwiftUI
import MapKit
import FirebaseFirestore

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Observable properties
    @Published var isShowingDetailView = false
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.350710, longitude: -71.090980),
                                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @Published var mapItems: [CachedHost: Optional<CachedEvent>] = [:]
    @Published var alertItem: AlertItem?
    @Published var isLoading = false
    @Published var userLocation: CLLocation?
    @Published var hostEvents: [CachedHost: CachedEvent] = [:]
    
    let deviceLocationManager = CLLocationManager()
    
    // Initialize the view model and set the delegate for the location manager
    override init() {
        super.init()
        deviceLocationManager.delegate = self
    }
    
    // Request always-on location permission
    func requestAlwaysOnLocationPermission() {
        deviceLocationManager.requestAlwaysAuthorization()
    }
    
    // Update the user's location when it changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        userLocation = currentLocation
        withAnimation {
            region = MKCoordinateRegion(center: currentLocation.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
    }
    
    // Handle location manager errors
    @MainActor func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alertItem = AlertContext.locationManagerFailed
        print("DEBUG: LocationManager did fail with error. \(error.localizedDescription)")
    }
    
    // Fetch and process map items
    @MainActor func getMapItems() {
        Task {
            do {
                let todayEvents = try await EventCache.shared.fetchEvents(filter: .today)
                var hosts = try await HostCache.shared.fetchHosts(filter: .all)
                
                print("DEBUG: today events fetched!. \(String(describing: todayEvents))")
                print("DEBUG: hosts fetched!. \(String(describing: hosts))")

                for var host in hosts {
                    guard let hostId = host.id else { return }
                    
                    if let currentEvent = todayEvents.first(where: { $0.hostUuid == hostId }) {
                        host.hasCurrentEvent = true
                        
                        try HostCache.shared.cacheHost(host)
                        try await updateHostCoordinates(for: &host, with: currentEvent)

                        mapItems.updateValue(currentEvent, forKey: host)
                    } else {
                        mapItems.updateValue(nil, forKey: host)
                    }
                }
                
                print("DEBUG: Map Items fetched!. \(mapItems)")
            } catch {
                alertItem = AlertContext.unableToGetMapItems
                print("DEBUG: Error getting map items. \(error.localizedDescription)")
            }
        }
    }
    
    // Update a map item for a given host with an optional event
    @MainActor func updateMapItem(for host: CachedHost, with event: CachedEvent? = nil) {
        self.mapItems.updateValue(event, forKey: host)
    }
    
    
    func getEventForGuestlist() {
        Task {
            do {
                guard let privileges = AuthViewModel.shared.currentUser?.hostPrivileges else { return }
                print("DEBUG: PRIV \(privileges)")
                var hostIds: [String] = []
                hostIds = privileges.keys.compactMap({ $0.self })
                print("DEBUG: HOSTIDS \(hostIds)")
                let hosts = try await HostCache.shared.getHosts(from: hostIds)
                print("DEBUG: HOSTS \(hosts)")
                
                for host in hosts {
                    guard let hostId = host.id else { return }
                    guard let event = try await EventCache.shared.fetchEvents(filter: .hostEvents(uid: hostId)).first else { return }
                    print("DEBUG: EVENT \(event)")
                    
                    DispatchQueue.main.async {
                        self.hostEvents.updateValue(event, forKey: host)
                        print("DEBUG: Host event for guest list updated. \(self.hostEvents)")
                    }
                }
            } catch {
//                alertItem = AlertContext.unableToGetMapItems
                print("DEBUG: Error getting event. \(error)")
            }
        }
    }
    
    // Update the host's coordinates based on the event's address
    private func updateHostCoordinates(for host: inout CachedHost, with event: CachedEvent) async throws {
        if let hostAddress = host.address {
            if hostAddress != event.address {
                if let coords = try await event.address.coordinates() {
                    host.location = Coordinate(CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude))
                    print("DEBUG: Host coords are changed to the event coords.")
                    try HostCache.shared.cacheHost(host)
                    await updateMapItem(for: host, with: event)
                }
            }
        } else {
            if let coords = try await event.address.coordinates() {
                host.location = Coordinate(CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude))
                print("DEBUG: Host did not have coords so changed to event coords.")
                try HostCache.shared.cacheHost(host)
                await updateMapItem(for: host, with: event)
            }
        }
    }

    private func fetchHostsByLocation() async throws -> [CachedHost] {
        // Needs to be changed in the future so users are fetched near the user
        return try await HostCache.shared.fetchHosts(filter: .byLocation(location: region.center))
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
