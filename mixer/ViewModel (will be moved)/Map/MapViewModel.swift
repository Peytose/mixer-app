////
////  MapViewModel.swift
////  mixer
////
////  Created by Peyton Lyons on 2/4/23.
////
//
//import SwiftUI
//import MapKit
//import FirebaseFirestore
//
//final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
//    // Observable properties
//    @Published var isShowingDetailView = false
//    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.350710, longitude: -71.090980),
//                                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//    @Published var mapItems: [Host: Optional<Event>] = [:]
//    @Published var alertItem: AlertItem?
//    @Published var isLoading = false
//    @Published var userLocation: CLLocation?
//    @Published var hostEventsDict: [Host: [Event]] = [:]
//    @Published var hostDetailViewModel: HostDetailViewModel?
//    @Published var eventDetailViewModel: EventDetailViewModel?
//    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
//    
//    let deviceLocationManager = CLLocationManager()
//    
//    // Initialize the view model and set the delegate for the location manager
//    override init() {
//        super.init()
//        deviceLocationManager.delegate = self
//        deviceLocationManager.desiredAccuracy = kCLLocationAccuracyBest
//        deviceLocationManager.startUpdatingLocation()
//    }
//    
//    func requestAlwaysOnLocationPermission() {
//        if deviceLocationManager.authorizationStatus == .notDetermined {
//            deviceLocationManager.requestAlwaysAuthorization()
//        } else if deviceLocationManager.authorizationStatus == .authorizedWhenInUse || deviceLocationManager.authorizationStatus == .authorizedAlways {
//            recenterMap()
//        }
//        HapticManager.playLightImpact()
//    }
//    
//    func recenterMap() {
//        guard let currentLocation = deviceLocationManager.location else { return }
//        let newRegion = MKCoordinateRegion(center: currentLocation.coordinate,
//                                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        DispatchQueue.main.async {
//            self.region = newRegion
//        }
//    }
//    
//    // Update the user's location when it changes
//    @MainActor func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let currentLocation = locations.last else { return }
//        DispatchQueue.main.async {
//            self.userLocation = currentLocation
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        DispatchQueue.main.async {
//            self.authorizationStatus = status
//        }
//    }
//    
//    // Handle location manager errors
//    @MainActor func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        alertItem = AlertContext.locationManagerFailed
//        print("DEBUG: LocationManager did fail with error. \(error.localizedDescription)")
//    }
//    
//    // Fetch and process map items
//    @MainActor func getMapItems() {
//        Task {
//            do {
//                isLoading = true
//                
//                let currentEvents = await UserService.getTodayEvents()
//                    .filter({ $0.startDate.compare(Timestamp()) == .orderedAscending })
//                var hosts = try await HostCache.shared.fetchHosts(filter: .all)
//                
//                print("DEBUG: today events fetched!. \(String(describing: currentEvents))")
//                print("DEBUG: hosts fetched!. \(String(describing: hosts))")
//
//                for var host in hosts {
//                    guard let hostId = host.id else {
//                        isLoading = false
//                        return
//                    }
//                    
//                    if let currentEvent = currentEvents.first(where: { $0.hostUuid == hostId }) {
//                        host.hasCurrentEvent = true
//                        
//                        try HostCache.shared.cacheHost(host)
//                        try await updateHostCoordinates(for: &host, with: currentEvent)
//
//                        updateMapItem(for: host, with: currentEvent)
//                    } else {
//                        updateMapItem(for: host)
//                    }
//                }
//                
//                isLoading = false
//                print("DEBUG: Map Items fetched!. \(mapItems)")
//            } catch {
//                isLoading = false
//                alertItem = AlertContext.unableToGetMapItems
//                print("DEBUG: Error getting map items. \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    // Update a map item for a given host with an optional event
//    private func updateMapItem(for host: Host, with event: Event? = nil) {
//        DispatchQueue.main.async {
//            self.mapItems.updateValue(event, forKey: host)
//        }
//    }
//    
//    
//    @MainActor func getEventsForGuestlist() {
//        Task {
//            do {
//                guard let privileges = AuthViewModel.shared.currentUser?.hostPrivileges else { return }
//                print("DEBUG: PRIV \(privileges)")
//                var hostIds: [String] = []
//                hostIds = privileges.keys.compactMap({ $0.self })
//                print("DEBUG: HOSTIDS \(hostIds)")
//                let hosts = try await HostCache.shared.getHosts(from: hostIds)
//                print("DEBUG: HOSTS \(hosts)")
//                
//                for host in hosts {
//                    guard let hostId = host.id else { return }
//                    
//                    // Get all events for this host
//                    let events = try await EventCache.shared.fetchEvents(filter: .hostEvents(uid: hostId))
//                    print("DEBUG: EVENTS \(events)")
//                    
//                    let sortedEvents = events.sortedByStartDate()
//                    
//                    DispatchQueue.main.async {
//                        self.hostEventsDict.updateValue(sortedEvents, forKey: host)
//                        print("DEBUG: Host event for guest list updated. \(self.hostEventsDict)")
//                    }
//                }
//            } catch {
//                alertItem = AlertContext.unableToGetGuestlistEvents
//                print("DEBUG: Error getting event. \(error)")
//            }
//        }
//    }
//    
//    // Update the host's coordinates based on the event's address
//    private func updateHostCoordinates(for host: inout Host, with event: Event) async throws {
//        if let hostAddress = host.address {
//            if hostAddress != event.address {
//                if let coords = try await event.address.coordinates() {
//                    host.location = Coordinate(CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude))
//                    print("DEBUG: Host coords are changed to the event coords.")
//                    HostCache.shared.cacheHost(host)
//                    updateMapItem(for: host, with: event)
//                }
//            }
//        } else {
//            if let coords = try await event.address.coordinates() {
//                host.location = Coordinate(CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude))
//                print("DEBUG: Host did not have coords so changed to event coords.")
//                HostCache.shared.cacheHost(host)
//                updateMapItem(for: host, with: event)
//            }
//        }
//    }
//
//    private func fetchHostsByLocation() async throws -> [Host] {
//        // Needs to be changed in the future so users are fetched near the user
//        return try await HostCache.shared.fetchHosts(filter: .byLocation(location: region.center))
//    }
//    
//    private func showLoadingView() { isLoading = true }
//    private func hideLoadingView() { isLoading = false }
//}