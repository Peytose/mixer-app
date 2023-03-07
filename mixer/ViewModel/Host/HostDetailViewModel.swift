//
//  HostDetailViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import CoreLocation
import MapKit

final class HostDetailViewModel: ObservableObject {
    @Published var host: CachedHost
    @Published var recentEvents: [CachedEvent]   = []
    @Published var upcomingEvents: [CachedEvent] = []
    private (set) var coordinates: CLLocationCoordinate2D?
    
    init(host: CachedHost) {
        self.host = host
        getHostCoordinates()
        getHostUpcomingEvents()
        getHostPastEvents()
    }
    
    
    func getDirectionsToLocation(coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name = host.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    
    private func getHostCoordinates() {
        guard let _ = host.address else { return }
        if let longitude = host.longitude, let latitude = host.latitude {
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    
    private func getHostPastEvents() {
        guard let hostId = host.id else { return }
        
        Task {
            do {
                let events = try await EventCache.shared.fetchPastEvents(for: .host, id: hostId)
                
                DispatchQueue.main.async { self.recentEvents = events }
            } catch {
                print("DEBUG: Error getting host's past events. \(error.localizedDescription)")
            }
        }
    }
    
    
    private func getHostUpcomingEvents() {
        guard let hostId = host.id else { return }
        
        Task {
            do {
                let futureEvents = try await EventCache.shared.fetchFutureEvents()
                let hostEvents = futureEvents.filter({ $0.hostUuid == hostId })
                
                DispatchQueue.main.async { self.upcomingEvents = hostEvents }
            } catch {
                print("DEBUG: Error getting host's upcoming events. \(error.localizedDescription)")
            }
        }
    }
}
