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
    @Published var isShowingDetailView = false
    @Published var region              = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.350710,
                                                                                           longitude: -71.090980),
                                                            span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                                   longitudeDelta: 0.01))
    @Published var mapItems: [CachedHost: CachedEvent?] = [:]
    @Published var alertItem: AlertItem?
    @Published var isLoading = false
    
    let deviceLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        deviceLocationManager.delegate = self
    }
    
    
    func requestAllowOnceLocationPermission() {
        deviceLocationManager.requestLocation()
    }
    
    
    @MainActor func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return } // return error
        
        withAnimation {
            region = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
    }
    
    
    @MainActor func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: LocationManager did fail with error. \(error.localizedDescription)")
    }
    
    
    @MainActor func getMapItems() {
        Task {
            do {
                let todayEvents = try await EventCache.shared.fetchTodayEvents()
                print("DEBUG: todayEvents :        \(todayEvents)")
                let hosts = try await HostCache.shared.fetchHosts()
                print("DEBUG: hosts       :        \(hosts)")
                
                for var host in hosts {
                    host.hasCurrentEvent = false
                    
                    if let _ = host.address, let _ = host.latitude, let _ = host.longitude {
                        self.mapItems.updateValue(CachedEvent?.none, forKey: host)
                        print("DEBUG: mapItems :   \(mapItems.keys.compactMap { $0 })")
                    }
                }
                
                for var event in todayEvents.filter({ $0.endDate.dateValue() > Date() && $0.startDate.dateValue() < Date() }) {
                    event.hasStarted = true
                    try EventCache.shared.cacheEvent(event)
                    print("DEBUG: Updated event cache to reflect that event \(event.id ?? "") is current..")
                    
                    var host = try await HostCache.shared.getHost(withId: event.hostUuid)
                    host.hasCurrentEvent = true
                    print("DEBUG: Host \(event.hostUuid) has a current event.")
                    
                    if let hostAddress = host.address {
                        if hostAddress != event.address {
                            if let coords = try await event.address.coordinates() {
                                host.latitude = coords.latitude
                                host.longitude = coords.longitude
                                print("DEBUG: Host coords are changed to the event coords.")
                                try await HostCache.shared.cacheHost(host)
                                mapItems.updateValue(event, forKey: host)
                            }
                        }
                    } else {
                        if let coords = try await event.address.coordinates() {
                            host.latitude = coords.latitude
                            host.longitude = coords.longitude
                            print("DEBUG: Host did not have coords so changed to event coords.")
                            try await HostCache.shared.cacheHost(host)
                            mapItems.updateValue(event, forKey: host)
                        }
                    }
                }
            } catch {
                print("DEBUG: Error getting map items! \(error.localizedDescription)")
            }
        }
    }
    
    
    //    func refresh(for eventManager: EventManager, for hostManager: HostManager) {
    //        EventCache.shared.clearCache()
    //        HostCache.shared.clearCache()
    //        eventManager.currentAndFutureEvents = []
    //        eventManager.pastEvents = []
    //        hostManager.hosts = []
    //    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
