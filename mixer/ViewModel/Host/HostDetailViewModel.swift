//
//  HostDetailViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
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
    
//    func fetchRecentEvents() {
//        guard let hostId = host.id else { return }
//        COLLECTION_EVENTS.whereField("hostUuid", isEqualTo: hostId).getDocuments { snapshot, _ in
//            guard let documents = snapshot?.documents else { return }
//            self.recentEvents = documents.compactMap({ try? $0.data(as: Event.self) })
//        }
//    }
}
