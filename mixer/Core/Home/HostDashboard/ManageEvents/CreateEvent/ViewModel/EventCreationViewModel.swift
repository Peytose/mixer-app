//
//  EventCreationViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/16/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import FirebaseFirestore
import MapKit

class EventCreationViewModel: NSObject, ObservableObject, AmenityHandling {
    @Published var title                       = ""
    @Published var eventDescription            = "" // Renamed because NSObject has 'description' property
    @Published var plannerUsername             = ""
    @Published var hostIds                     = Set<String>()
    @Published var hostNames                   = Set<String>()
    @Published var plannerNameMap              = [String: String]()
    @Published var plannerAssociatedHosts      = [String: [String]]()
    @Published var plannerHostStatusMap            = [String: PlannerStatus]()
    @Published var note                        = ""
    @Published var guestLimitStr               = ""
    @Published var memberInviteLimitStr        = ""
    @Published var startDate                   = Date()
    @Published var endDate                     = Date().addingTimeInterval(80600)
    @Published var altAddress                  = ""
    @Published var selectedAmenities           = Set<EventAmenity>()
    @Published var bathroomCount               = 0
    @Published var type                        = EventType.party
    @Published private(set) var isEventCreated = false
    @Published var isShowingAddPlannerAlert    = false
    @Published var isShowingHostSelectionAlert = false
    @Published var isInviteOnly                = false
    @Published var isPrivate                   = false
    @Published var isManualApprovalEnabled     = false
    @Published var containsAlcohol                  = false
    @Published var isCheckInViaMixer           = true
    @Published var isLoading                   = false
    
    @Published var selectedDeadlineOption: DeadlineOption = .oneDayBefore {
        didSet {
            self.cutoffDate = selectedDeadlineOption.deadline(from: self.startDate)
        }
    }
    @Published var cutoffDate                  = Date.now
    @Published var selectedImage: UIImage?
    
    // Location search properties
    @Published var isLocationSearchActive      = true
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedLocation: UserSelectedLocation?
    
    @Published var cost: Float?
    @Published var alcoholPresence: Bool?
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
        
        func presets() -> (Bool, Bool, Bool) {
            switch self {
            case .postIt: return (false, false, false)
            case .publicOpen: return (false, false, true)
            case .publicInvite: return (false, true, true)
            case .privateOpen: return (true, false, true)
            case .privateInvite: return (true, true, true)
            }
        }
    }
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        
        searchCompleter.delegate      = self
        searchCompleter.queryFragment = queryFragment
    }
    
    
    func resetCheckInRelatedOptions() {
        self.isManualApprovalEnabled = false
        self.guestLimitStr = ""
        self.memberInviteLimitStr = ""
    }
    
    
    func setDefaultOptions(for option: DefaultPrivacyOption) {
        let presets = option.presets()
        
        DispatchQueue.main.async {
            self.isPrivate = presets.0
            self.isInviteOnly = presets.1
            self.isCheckInViaMixer = presets.2
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
            case .costAndAmenities: return AnyView(EventAmenityAndCost())
            case .review: return AnyView(ReviewCreatedEventView())
        }
    }
    
    
    func hostSelectionButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        
        for (hostId, hostNameAndUserId) in self.plannerAssociatedHosts {
            let button = ActionSheet.Button.default(Text(hostNameAndUserId[0])) {
                let key = "\(hostNameAndUserId[1])-\(hostId)"
                self.plannerHostStatusMap.updateValue(PlannerStatus.pending, forKey: key)
                self.hostNames.insert(hostNameAndUserId[0])
                self.isShowingHostSelectionAlert = false
            }
            buttons.append(button)
        }
        
        return buttons
    }
    
    
    func addPlanner() {
        isShowingAddPlannerAlert = false
        let queryKey = QueryKey(collectionPath: "users",
                                filters: ["username == \(plannerUsername.lowercased())"],
                                limit: 1)
        
        COLLECTION_USERS
            .whereField("username", isEqualTo: self.plannerUsername.lowercased())
            .limit(to: 1)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 7200) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching user with username \(self.plannerUsername): \(error.localizedDescription)")
                    return
                }

                guard let user = try? snapshot?.documents.first?.data(as: User.self),
                      let userId = user.id else { return }

                if let associatedHosts = user.hostIdToMemberTypeMap?.filter({ $0.value.rawValue > 0 }).keys {
                    HostManager.shared.fetchHosts(with: Array(associatedHosts)) { hosts in
                        self.plannerUsername = ""

                        if !self.isShowingAddPlannerAlert && hosts.count > 1 {
                            for host in hosts {
                                guard let hostId = host.id else { return }
                                self.plannerAssociatedHosts.updateValue([host.name, userId], forKey: hostId)
                            }
                            self.isShowingHostSelectionAlert = true
                        } else {
                            guard let host = hosts.first,
                                  let hostId = host.id else { return }
                            let key = "\(userId)-\(hostId)"
                            self.plannerHostStatusMap.updateValue(PlannerStatus.pending, forKey: key)
                            self.hostNames.insert(host.name)
                        }

                        self.plannerNameMap.updateValue(user.displayName, forKey: userId)
                        print("DEBUG: Planner Confirmations: \(self.plannerHostStatusMap)")
                    }
                }
            }
    }
    
    
    func createEvent() {
        self.showLoadingView()
        guard let image = selectedImage else {
            self.hideLoadingView()
            return
        }
        
        ImageUploader.uploadImage(image: image, type: .event) { imageUrl in
            // Needs attention (issue: only allows users to be single host)
            guard let host = UserService.shared.user?.associatedHosts?.first,
                  let mainHostId = host.id,
                  let userId = Auth.auth().currentUser?.uid,
                  let location = self.selectedLocation else {
                self.hideLoadingView()
                return
            }
            
            let geoPoint = GeoPoint(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
            
            let key = "\(userId)-\(mainHostId)"
            self.plannerHostStatusMap.updateValue(PlannerStatus.primary,
                                                  forKey: key)
            self.hostIds.insert(mainHostId)
            self.hostNames.insert(host.name)
            
            var event = Event(hostIds: Array(self.hostIds),
                              hostNames: Array(self.hostNames),
                              plannerHostStatusMap: self.plannerHostStatusMap,
                              timePosted: Timestamp(),
                              eventImageUrl: imageUrl,
                              title: self.title,
                              description: self.eventDescription,
                              type: self.type,
                              note: nil,
                              address: location.title,
                              altAddress: nil,
                              geoPoint: geoPoint,
                              amenities: Array(self.selectedAmenities),
                              isCheckInViaMixer: self.isCheckInViaMixer,
                              containsAlcohol: self.alcoholPresence ?? false,
                              startDate: Timestamp(date: self.startDate),
                              endDate: Timestamp(date: self.endDate),
                              cutOffDate: nil,
                              guestLimit: nil,
                              memberInviteLimit: nil,
                              isPrivate: self.isPrivate,
                              isInviteOnly: self.isInviteOnly,
                              isManualApprovalEnabled: self.isManualApprovalEnabled,
                              cost: nil)
            
            if !self.note.isEmpty {
                event.note = self.note
            }
            
            if !self.altAddress.isEmpty {
                event.altAddress = self.altAddress
            }
            
            if self.bathroomCount != 0 {
                event.bathroomCount = self.bathroomCount
            }

            if self.cutoffDate >= Date.now {
                event.cutOffDate = Timestamp(date: self.cutoffDate)
            }

            if let guestLimit = Int(self.guestLimitStr), guestLimit > 0 {
                event.guestLimit = guestLimit
            }

            if let memberInviteLimit = Int(self.memberInviteLimitStr), memberInviteLimit > 0 {
                event.memberInviteLimit = memberInviteLimit
            }

            if let costValue = self.cost, costValue > 0 {
                event.cost = costValue
            }
            
            guard let encodedEvent = try? Firestore.Encoder().encode(event) else {
                self.hideLoadingView()
                return
            }
            
            let newDocumentReference = COLLECTION_EVENTS.document()

            let batch = Firestore.firestore().batch()
            batch.setData(encodedEvent, forDocument: newDocumentReference)
            
            // Update the event's id with the document ID from Firestore
            event.id = newDocumentReference.documentID
            
            self.reset()
            self.isEventCreated = true
            self.hideLoadingView()

            NotificationsViewModel.preparePlannerNotificationBatch(for: event,
                                                               type: .plannerInvited,
                                                               within: batch)
            
            batch.commit { error in
                if let error = error {
                    print("DEBUG: Error creating event: \(error.localizedDescription)")
                    return
                }
                
                HapticManager.playSuccess()
            }
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
    
    
    private func reset() {
        title                   = ""
        eventDescription        = ""
        note                    = ""
        guestLimitStr           = ""
        memberInviteLimitStr    = ""
        startDate               = Date()
        endDate                 = Date().addingTimeInterval(80600)
        altAddress              = ""
        selectedAmenities       = Set<EventAmenity>()
        type                    = EventType.party
        isLoading               = false
        isInviteOnly            = false
        isPrivate               = false
        isManualApprovalEnabled = false
        isCheckInViaMixer       = true
        results                 = []
        selectedLocation        = nil
        cost                    = nil
        alcoholPresence         = nil
        bathroomCount           = 0
        queryFragment           = ""
    }
    
    
    func removePlanner(withId plannerId: String) {
        plannerNameMap.removeValue(forKey: plannerId)
        plannerHostStatusMap.removeValue(forKey: plannerId)
    }
    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
