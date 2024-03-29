//
//  HostViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import CoreLocation
import MapKit

@MainActor
final class HostViewModel: ObservableObject {
    @Published var recentEvents           = [Event]()
    @Published var currentAndFutureEvents = [Event]()
    @Published var host: Host
    
    init(host: Host) {
        self.host = host
        
        self.fetchRecentEvents()
        self.fetchCurrentAndUpcomingEvents()
    }
    
    
    func getDirectionsToLocation(coordinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name  = host.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    
    func fetchRecentEvents() {
        guard let hostUid = host.id else { return }
        
        let thirtyDaysBefore = Timestamp(date: Calendar.current.date(byAdding: .day,
                                                                     value: -30,
                                                                     to: Date())!)
        let queryKey = QueryKey(collectionPath: "events",
                                filters: ["hostIds contains \(hostUid)",
                                          "endDate in Past",
                                          "endDate in LastMonth"])
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostUid)
            .whereField("endDate", isLessThan: Timestamp())
            .whereField("endDate", isGreaterThan: thirtyDaysBefore)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 7200) { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                self.recentEvents = events.sortedByStartDate(true)
            }
    }
    
    
    func fetchCurrentAndUpcomingEvents() {
        guard let hostUid = host.id else { return }
        
        let events = EventManager.shared.events.filter({
            $0.hostIds.contains(where: { $0 == hostUid }) &&
            $0.endDate > Timestamp()
        })
        
        self.currentAndFutureEvents = Array(events).sortedByStartDate()
    }
}
