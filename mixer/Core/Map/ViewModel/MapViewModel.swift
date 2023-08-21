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

class MapViewModel: ObservableObject {
    // MARK: - Properties
    @Published var hosts                   = Set<Host>()
    @Published var events                  = Set<Event>()
    @Published var shownMapTypes           = [MapItemType.event, MapItemType.host]
    @Published var mapItems                = Set<MixerMapItem>()
    @Published var showLocationDetailsCard = false
    @Published var selectedMixerMapItem: MixerMapItem?
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var alertItem: AlertItem?
    
    private let hostManager        = HostManager.shared
    private let eventManager       = EventManager.shared
    private var cancellable        = Set<AnyCancellable>()
    
    var userLocation: CLLocationCoordinate2D?
    
    init() {
        // Subscribe to hosts from HostManager
        hostManager.$hosts
            .map { hosts in hosts.compactMap { MixerMapItem(host: $0) } }
            .sink { [weak self] locations in
                self?.mapItems.formUnion(locations)
            }
            .store(in: &cancellable)
        
        // Subscribe to events from EventManager
        eventManager.$events
            .map { events in events.compactMap { MixerMapItem(event: $0) } }
            .sink { [weak self] locations in
                self?.mapItems.formUnion(locations)
            }
            .store(in: &cancellable)
    }
}

// MARK: - Location Search Helpers
extension MapViewModel {
    func addressFromPlacemark(_ placemark: CLPlacemark) -> String {
        var result = ""
        
        if let thoroughfare = placemark.thoroughfare {
            result += thoroughfare
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            result += " \(subThoroughfare)"
        }
        
        if let subAdministrativeArea = placemark.subAdministrativeArea {
            result += ", \(subAdministrativeArea)"
        }
        
        return result
    }
    
    
    func getPlacemark(forLocation location: CLLocation, completion: @escaping(CLPlacemark?, Error?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            completion(placemark, nil)
        }
    }
    
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler) {
        let searchRequest                  = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search                         = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
    
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void) {
        let userPlacemark   = MKPlacemark(coordinate: userLocation)
        let destPlacement   = MKPlacemark(coordinate: destination)
        let request         = MKDirections.Request()
        request.source      = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destPlacement)
        let directions      = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error {
                print("DEBUG: Failed to get directions with error \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else { return }
            self.configurePickupAndDropOffTime(with: route.expectedTravelTime)
            completion(route)
        }
    }
    
    
    func configurePickupAndDropOffTime(with expectedTravelTime: Double) {
        let formatter        = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime  = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
}
