//
//  EventCreationViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/16/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import MapKit

class EventCreationViewModel: NSObject, ObservableObject {
    @Published var title                   = ""
    @Published var eventDescription        = "" // Renamed because NSObject has 'description' property
    @Published var note                    = ""
    @Published var guestLimitStr           = ""
    @Published var guestInviteLimitStr     = ""
    @Published var memberInviteLimitStr    = ""
    @Published var startDate               = Date()
    @Published var endDate                 = Date().addingTimeInterval(80600)
    @Published var altAddress              = ""
    @Published var selectedAmenities       = Set<EventAmenity>()
    @Published var type                    = EventType.party
    @Published var isLoading               = false
    @Published var selectedCheckInMethod   = CheckInMethod.manual
    @Published var isInviteOnly            = false
    @Published var isPrivate               = false
    @Published var isManualApprovalEnabled = false
    @Published var isGuestlistEnabled      = false
    @Published var checkInMethod           = [CheckInMethod.manual]
    
    @Published var registrationDeadlineDate: Date?
    @Published var selectedImage: UIImage?
    
    // Location search properties
    @Published var isLocationSearchActive = true
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedLocation: UserSelectedLocation?
    
    @Published var cost: Float?
    @Published var alcoholPresence: Bool?
    @Published var bathroomCount: Int?
    @Published var alertItem: AlertItem?
    
    private let searchCompleter = MKLocalSearchCompleter()
    var queryFragment: String   = "" {
        didSet {
            print("DEBUG: Query fragment is \(queryFragment)")
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    enum DefaultPrivacyOption: Int, CustomStringConvertible, CaseIterable {
        case postIt
        case publicOpen
        case publicInvite
        case privateOpen
        case privateInvite
        
        var description: String {
            switch self {
            case .postIt: return "Just post it"
            case .publicOpen: return "Public, Open Invite"
            case .publicInvite: return "Public, Invite-Only"
            case .privateOpen: return "Private, Open Invite"
            case .privateInvite: return "Private, Invite-Only"
            }
        }
        
        func presets() -> (Bool, Bool, CheckInMethod) {
            switch self {
            case .postIt: return (false, false, .outOfApp)
            case .publicOpen: return (false, false, .qrCode)
            case .publicInvite: return (false, true, .qrCode)
            case .privateOpen: return (true, false, .qrCode)
            case .privateInvite: return (true, true, .qrCode)
            }
        }
    }
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        
        searchCompleter.delegate      = self
        searchCompleter.queryFragment = queryFragment
    }
    
    
    func setDefaultOptions(for option: DefaultPrivacyOption) {
        let presets = option.presets()
        
        DispatchQueue.main.async {
            self.isPrivate = presets.0
            self.isInviteOnly = presets.1
            self.selectedCheckInMethod = presets.2
        }
    }
    
    
    func isActionButtonEnabled(forState state: EventCreationState) -> Bool {
        switch state {
            case .basicInfo:
                return !title.isEmpty &&
                !eventDescription.isEmpty &&
                title.count <= 50 &&
                eventDescription.count <= 150 &&
                note.count <= 250
            case .locationAndDates:
                return selectedLocation != nil
            default:
                return true
        }
    }
    
    
    func actionForState(_ state: Binding<EventCreationState>) {
        switch state.wrappedValue {
            case .basicInfo,
                    .locationAndDates,
                    .guestsAndInvitations,
                    .costAndAmenities:
                self.next(state)
            case .review:
                self.createEvent()
        }
    }
    
    
    func viewForState(_ state: EventCreationState) -> some View {
        switch state {
            case .basicInfo: return AnyView(BasicEventInfo())
            case .locationAndDates: return AnyView(EventLocationAndDates())
            case .guestsAndInvitations: return AnyView(EventGuestsAndInvitations())
            case .costAndAmenities: return AnyView(Text("EventAmenityAndCost()"))
            case .review: return AnyView(Text("ReviewCreatedEventView()"))
        }
    }
    
    
    func createEvent() {
        guard let image = selectedImage else {return }
        
        ImageUploader.uploadImage(image: image, type: .event) { imageUrl in
            // Needs attention (issue: only allows users to be single host)
            guard let host = UserService.shared.user?.associatedHosts?.first, let hostId = host.id else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            guard let location = self.selectedLocation else { return }
            let geoPoint = GeoPoint(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
            
            let event = Event(hostId: hostId,
                              postedByUserId: uid,
                              hostName: host.name,
                              timePosted: Timestamp(),
                              eventImageUrl: imageUrl,
                              title: self.title,
                              description: self.description,
                              type: self.type,
                              note: self.note,
                              address: location.title,
                              altAddress: self.altAddress,
                              geoPoint: geoPoint,
                              amenities: Array(self.selectedAmenities),
                              checkInMethods: self.checkInMethod,
                              containsAlcohol: self.alcoholPresence ?? false,
                              startDate: Timestamp(date: self.startDate),
                              endDate: Timestamp(date: self.endDate),
                              //                                  registrationDeadlineDate: self.registrationDeadlineDate,
                              guestLimit: Int(self.guestLimitStr),
                              guestInviteLimit: Int(self.guestInviteLimitStr),
                              memberInviteLimit: Int(self.memberInviteLimitStr),
                              isPrivate: self.isPrivate,
                              isInviteOnly: self.isInviteOnly,
                              isManualApprovalEnabled: self.isManualApprovalEnabled,
                              isGuestlistEnabled: self.isGuestlistEnabled,
                              cost: self.cost)
            
            guard let encodedEvent = try? Firestore.Encoder().encode(event) else { return }
            
            COLLECTION_EVENTS.addDocument(data: encodedEvent)
        }
    }
}

// MARK: - Location Search Helpers
extension EventCreationViewModel {
    func selectLocation(_ localSearch: MKLocalSearchCompletion) {
        locationSearch(forLocalSearchCompletion: localSearch) { result, error in
            if let error = error {
                print("DEBUG: Location search failed with error \(error.localizedDescription)")
                return
            }
            
            guard let item = result?.mapItems.first else { return }
            let coordinate = item.placemark.coordinate
            
            self.isLocationSearchActive = false
            self.queryFragment          = localSearch.title
            self.selectedLocation       = UserSelectedLocation(title: localSearch.title,
                                                               coordinate: coordinate)
            self.results                = []
        }
    }
    
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler) {
        let searchRequest                  = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search                         = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
}

extension EventCreationViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}

// MARK: - Helper functions
extension EventCreationViewModel {
    func next(_ state: Binding<EventCreationState>) {
        let nextIndex = min(state.wrappedValue.rawValue + 1, EventCreationState.allCases.last!.rawValue)
        
        if let nextState = EventCreationState(rawValue: nextIndex) {
            state.wrappedValue = nextState
        }
    }
    
    
    func previous(_ state: Binding<EventCreationState>) {
        let previousIndex = max(state.wrappedValue.rawValue - 1, EventCreationState.allCases.first!.rawValue)
        
        if let previousState = EventCreationState(rawValue: previousIndex) {
            state.wrappedValue = previousState
        }
    }
    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
