//
//  HomeViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine
import MapKit

enum MapSearchType: String, CaseIterable {
    case event = "Events"
    case host  = "Hosts"
}

class HomeViewModel: NSObject, ObservableObject {
    // MARK: - Properties
    @Published var hosts           = Set<Host>()
    @Published var events          = Set<Event>()
    @Published var guestlistEvents = Set<Event>()
    @Published var mapType         = MapSearchType.host
    private let service            = UserService.shared
    private var cancellable        = Set<AnyCancellable>()
    var currentUser: User?
    
    @Published var shownMapTypes = [MapSearchType.event]
    @Published var mapItems      = Set<MixerLocation>()
    @Published var results       = Set<MixerLocation>()
    @Published var searchText    = ""
    @Published var selectedMixerLocation: MixerLocation?
    @Published var selectedEvent: Event?
    @Published var selectedHost: Host?
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var alertItem: AlertItem?
    
    var userLocation: CLLocationCoordinate2D?
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        fetchUser()
        
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [self] _ in
                performSearch()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    private func reverseFetchLocation(from location: MixerLocation?) {
        guard let location = location else { return }
        
        switch location.state {
        case .event:
            guard let eventId = location.id else { return }
            COLLECTION_EVENTS
                .document(eventId)
                .getDocument { snapshot, _ in
                    guard let event = try? snapshot?.data(as: Event.self) else { return }
                    self.selectedEvent = event
                }
        case .host:
            guard let hostId = location.id else { return }
            COLLECTION_HOSTS
                .document(hostId)
                .getDocument { snapshot, _ in
                    guard let host = try? snapshot?.data(as: Host.self) else { return }
                    self.selectedHost = host
                }
        }
    }
    
    
    func performSearch() {
        if !searchText.isEmpty {
            // Search from preloaded locations first
            let items = mapItems.search(using: searchText)
            
            if !items.isEmpty {
                print("DEBUG: Got items from preloaded locations: \(items)")
                self.results = items
            } else {
                print("DEBUG: NO items from preloaded locations.")
            }
        }
    }
    
    
    // DEBUG: Func includes user for basing certain views on acc type
    func viewForState(_ state: MapViewState, user: User) -> some View {
        switch state {
        case .discovering:
            return AnyView(Text(""))
        case .routeEventPreview, .routeHostPreview, .polylineAdded:
            return AnyView(LocationDetailsCardView())
        default:
            break
        }
        
        return AnyView(Text(""))
    }
    
    
    // DEBUG: Func extracted for potential expansion
    func clearInput() {
        self.searchText = ""
        self.results    = []
    }
    
    
    // MARK: - User API
    func fetchUser() {
        service.$user
            .sink { user in
                self.currentUser = user
                guard let user = user else { return }
                
                for type in self.shownMapTypes {
                    switch type {
                        case .event:
                            self.fetchEvents()
                        case .host:
                            self.fetchHosts()
                    }
                }
                
                if let associatedHosts = user.associatedHosts, !associatedHosts.isEmpty {
                    print("DEBUG: executed func.")
                    self.fetchEventsForGuestlist(from: associatedHosts)
                } else {
                    print("DEBUG: did not execute func.")
                }
            }
            .store(in: &cancellable)
    }
}

// MARK: - Users API
extension HomeViewModel {
    func fetchHosts() {
        COLLECTION_HOSTS
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let hosts = documents.compactMap({ try? $0.data(as: Host.self) })
                self.hosts.formUnion(hosts)
                
                let locations = self.hosts.compactMap({ MixerLocation(host: $0) })
                self.mapItems.formUnion(locations)
            }
    }
    
    
    func fetchEvents() {
        COLLECTION_EVENTS
            .whereField("endDate", isGreaterThanOrEqualTo: Timestamp())
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                self.events.formUnion(events)
                
                let locations = events.compactMap({ MixerLocation(event: $0) })
                self.mapItems.formUnion(locations)
            }
    }
}

// MARK: - Hosts API
extension HomeViewModel {
    private func fetchEventsForGuestlist(from hosts: [Host]) {
        guard let hosts = currentUser?.associatedHosts else { return }
        
        for host in hosts {
            guard let hostId = host.id else { return }
            
            COLLECTION_EVENTS
                .whereField("hostId", isEqualTo: hostId)
                .whereField("startDate", isGreaterThan: Timestamp())
                .getDocuments { snapshot, error in
                    if let _ = error {
                        self.alertItem = AlertContext.unableToGetGuestlistEvents
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    let events = documents.compactMap({ try? $0.data(as: Event.self) }).sortedByStartDate()
                    self.guestlistEvents.formUnion(events)
                    print("DEBUG: Guestlist events. \(self.guestlistEvents)")
                }
        }
    }
}

// MARK: - Location Search Helpers
extension HomeViewModel {
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
    
    
    // DEBUG: Func extracted for potential expansion
    func selectLocation(_ location: MixerLocation) {
        self.selectedMixerLocation = location
        self.reverseFetchLocation(from: location)
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
