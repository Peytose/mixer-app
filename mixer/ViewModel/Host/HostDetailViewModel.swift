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
        if let longitude = host.location?.longitude, let latitude = host.location?.latitude {
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    
    private func getHostPastEvents() {
        guard let hostId = host.id else { return }
        
        Task {
            do {
                let events = try await EventCache.shared.fetchEvents(filter: .hostEvents(uid: hostId)).filter({
                    $0.endDate.dateValue() >= Calendar.current.date(byAdding: .day, value: -30, to: Date())! &&
                    $0.endDate.dateValue() < Date()
                })
                
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
                let futureEvents = try await EventCache.shared.fetchEvents(filter: .future)
                
                DispatchQueue.main.async { self.upcomingEvents = futureEvents.filter({ $0.hostUuid == hostId }) }
            } catch {
                print("DEBUG: Error getting host's upcoming events. \(error.localizedDescription)")
            }
        }
    }
}
