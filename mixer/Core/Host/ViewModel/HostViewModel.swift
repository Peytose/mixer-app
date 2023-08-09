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

final class HostViewModel: ObservableObject {
    @Published var recentEvents           = [Event]()
    @Published var currentAndFutureEvents = [Event]()
    let host: Host
    
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
        
        COLLECTION_EVENTS
            .whereField("hostUid", isEqualTo: hostUid)
            .whereField("endDate", isGreaterThan: Timestamp())
            .whereField("endDate", isLessThan: thirtyDaysBefore)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let events = documents
                    .compactMap({ try? $0.data(as: Event.self) })
                    .sortedByStartDate()
                
            }
    }
    
    
    func fetchCurrentAndUpcomingEvents() {
        guard let hostUid = host.id else { return }
        
        COLLECTION_EVENTS
            .whereField("hostUid", isEqualTo: hostUid)
            .whereField("endDate", isLessThan: Timestamp())
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let events = documents
                    .compactMap({ try? $0.data(as: Event.self) })
                    .sortedByStartDate()
            }
    }
}
