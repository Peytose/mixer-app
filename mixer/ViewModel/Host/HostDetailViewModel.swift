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
    @Published var isLoading: Bool = false
    @Published var isDataReady: Bool = false
    
    init(host: CachedHost) {
        self.host = host
        Task.init {
            await getHostCoordinates()
            await getHostUpcomingEvents()
            await getHostPastEvents()
            isDataReady = true
        }
    }
    
    
    func getDirectionsToLocation(coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name = host.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    
    @MainActor func getHostCoordinates() {
        isLoading = true
        guard let _ = host.address else {
            isLoading = false
            return
        }
        if let longitude = host.location?.longitude, let latitude = host.location?.latitude {
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            isLoading = false
        }
    }
    
    
    @MainActor func getHostPastEvents() {
        isLoading = true

        guard let hostId = host.id else {
            isLoading = false
            return
        }
        
        Task {
            do {
                self.recentEvents = try await EventCache.shared.fetchEvents(filter: .hostEvents(uid: hostId)).filter({
                    $0.endDate.dateValue() >= Calendar.current.date(byAdding: .day, value: -30, to: Date())! &&
                    $0.endDate.dateValue() < Date()
                }).sorted(by: { event1, event2 in
                    event1.startDate.compare(event2.startDate) == .orderedDescending
                })
                isLoading = false
            } catch {
                isLoading = false
                print("DEBUG: Error getting host's past events. \(error.localizedDescription)")
            }
        }
    }
    
    
    @MainActor func getHostUpcomingEvents() {
        isLoading = true
        
        guard let hostId = host.id else {
            isLoading = false
            return
        }
        
        Task {
            do {
                self.upcomingEvents = try await EventCache.shared.fetchEvents(filter: .hostEvents(uid: hostId))
                    .sorted(by: { event1, event2 in
                        event1.startDate.compare(event2.startDate) == .orderedAscending
                })
                isLoading = false
            } catch {
                isLoading = false
                print("DEBUG: Error getting host's upcoming events. \(error.localizedDescription)")
            }
        }
    }
}
