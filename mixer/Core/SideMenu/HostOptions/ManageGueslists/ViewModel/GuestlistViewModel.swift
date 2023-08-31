//
//  GuestlistViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import CodeScanner

enum UniversityExamples: String, CaseIterable {
    case mit = "MIT"
    case neu = "NEU"
    case bu = "BU"
    case harvard = "Harvard"
    case bc = "BC"
    case tufts = "Tufts"
    case simmons = "Simmons"
    case wellesley = "Wellesley"
    case berklee = "Berklee College of Music"
    case other = "Other"
}

class GuestlistViewModel: ObservableObject {
    @Published var selectedEvent: Event? {
        didSet {
            self.addGuestlistObserverForEvent()
        }
    }
    @Published var events: [Event] = []
    @Published var guests = [EventGuest]() {
        didSet {
            self.updateSectionedGuests()
        }
    }
    @Published var filteredGuests: [EventGuest] = []
    @Published private(set) var sectionedGuests: [String: [EventGuest]] = [:]

    @Published var selectedGuestSection: GuestStatus = .invited {
        didSet {
            refreshViewState()
        }
    }
    @Published var selectedGuest: EventGuest?
    @Published var selectedHost: Host?
    @Published var currentAlert: AlertType?
    @Published var alertItem: AlertItem? {
        didSet {
            currentAlert = .regular(alertItem)
        }
    }
    @Published var confirmationAlertItem: ConfirmationAlertItem? {
        didSet {
            currentAlert = .confirmation(confirmationAlertItem)
        }
    }

    @Published var viewState: ListViewState = .loading
    @Published var isShowingUserInfoModal = false
    @Published var username               = ""
    @Published var name                   = ""
    @Published var email                  = ""
    @Published var selectedUniversity: University?
    @Published var universityString       = ""
    @Published var status                 = GuestStatus.invited
    @Published var gender                 = Gender.man
    @Published var age                    = 18

    private let service = HostService.shared
    private var listener: ListenerRegistration?
    
    init(associatedHosts: [Host]) {
        self.selectedHost = associatedHosts.first
        self.fetchGuestlistEvents()
    }
    
    deinit {
        listener?.remove()
    }
    
    
    private func refreshViewState() {
        let filteredGuests = guests.filter({ $0.status == selectedGuestSection })
        self.filteredGuests = filteredGuests
        self.viewState = filteredGuests.isEmpty ? .empty : .list
    }
    
    
    func getPdfTitle() -> String {
        guard let eventName = self.selectedEvent?.title else { return "" }
        let purpose = "Attendance"
        let date = Timestamp().getTimestampString(format: "yyyy-MM-dd")
        let time = Timestamp().getTimestampString(format: "HHmm")

        return "\(eventName)_\(purpose)_\(date)_\(time)"
    }
    
    
    func getGuestlistSectionCountText() -> String {
        let count = self.filteredGuests.count
        
        return "\(count) guest\(count > 1 ? "s" : "")"
    }
    
    
    func fetchGuestlistEvents() {
        guard let hostId = selectedHost?.id else { return }
        
        COLLECTION_EVENTS
            .whereField("hostId", isEqualTo: hostId)
            .getDocuments { snapshot, error in
                if let _ = error {
                    self.alertItem = AlertContext.unableToGetGuestlistEvents
                }
                
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                let sortedEvents = events.sortedByStartDate()
                
                if let closestEvent = sortedEvents.first(where: { $0.startDate >= Timestamp() }) {
                    DispatchQueue.main.async {
                        self.events = sortedEvents
                        self.selectedEvent = closestEvent
                    }
                } else {
                    self.selectedEvent = sortedEvents.first
                }
            }
    }
}


// MARK: - Helpers for Searching and Handling Events
extension GuestlistViewModel {
    func filterGuests(with searchText: String) {
        guard !searchText.isEmpty else { return }
        
        let filteredGuests = guests.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
        
        guests = filteredGuests
    }

    
    @MainActor
    func changeEvent(to event: Event) {
        self.selectedEvent = event
    }
}

// MARK: - Helpers for Handling QR Code Scanning
extension GuestlistViewModel {
    @MainActor
    func handleScan(_ response: Result<ScanResult, ScanError>) {
        switch response {
            case .success(let result):
                self.handleScannedUser(result)
            case .failure(let error):
                print("DEBUG: Scanning failed due to \(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    private func handleScannedUser(_ result: ScanResult) {
        let uid = result.string
        
        guard uid.count <= 128, uid.range(of: "\\W", options: .regularExpression) == nil else {
            print("DEBUG: QR code data is not a valid DocumentID.")
            return
        }
        
        guard let selectedEvent = selectedEvent else { return }
        
        if let guest = guests.first(where: { $0.id == uid }), guest.status != .checkedIn {
            self.selectedGuest = guest
            self.checkIn()
        } else if !selectedEvent.isInviteOnly {
            let status: GuestStatus = selectedEvent.startDate > Timestamp() ? .invited : .checkedIn
            fetchAndAddUserToGuestlist(uid: uid, status: status)
        } else {
            print("DEBUG: User is not on guestlist")
        }
    }
    
    
    @MainActor
    private func fetchAndAddUserToGuestlist(uid: String, status: GuestStatus) {
        COLLECTION_USERS
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching user. \(error.localizedDescription)")
                    return
                }
                
                guard let user = try? snapshot?.data(as: User.self),
                      let eventId = self.selectedEvent?.id,
                      let userId = user.id else { return }
                
                self.service.addUserToGuestlist(eventUid: eventId, user: user, status: status) { error in
                    if let error = error {
                        print("DEBUG: Error adding user to guestlist. \(error.localizedDescription)")
                        return
                    }
                    
                    NotificationsViewModel.uploadNotification(toUid: userId,
                                                              type: .guestlistAdded,
                                                              host: self.selectedHost,
                                                              event: self.selectedEvent)
                }
            }
    }
}

// MARK: - CRUD Operations on Guests
extension GuestlistViewModel {
    @MainActor
    func createGuest() {
        guard let eventId = self.selectedEvent?.id,
              let currentUserName = UserService.shared.user?.name else { return }
        
        if let guest = self.guests.first(where: { $0.username == username }) {
            switch guest.status {
                case .invited:
                    self.alertItem = AlertContext.duplicateGuestInvite
                case .checkedIn:
                    self.alertItem = AlertContext.guestAlreadyJoined
            }
        } else {
            if username != "" {
                self.fetchUserAndAddToGuestlist(eventId: eventId,
                                                status: self.status,
                                                invitedBy: currentUserName)
            } else {
                self.addGuest(eventId: eventId,
                              status: self.status,
                              invitedBy: currentUserName)
            }
        }
    }

    
    private func fetchUserAndAddToGuestlist(eventId: String,
                                            status: GuestStatus,
                                            invitedBy: String? = nil,
                                            checkedInBy: String? = nil) {
        COLLECTION_USERS
            .whereField("username", isEqualTo: self.username)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting user from username: \(error.localizedDescription)")
                    return
                }
                
                guard let user = try? snapshot?.documents.first?.data(as: User.self),
                      let userId = user.id else { return }
                
                self.service.addUserToGuestlist(eventUid: eventId,
                                                user: user,
                                                status: status,
                                                invitedBy: invitedBy,
                                                checkedInBy: checkedInBy) { error in
                    if let error = error {
                        print("DEBUG: Error \(error.localizedDescription)")
                        self.alertItem = AlertContext.unableToAddGuest
                        return
                    }
                    
                    NotificationsViewModel.uploadNotification(toUid: userId,
                                                              type: .guestlistAdded,
                                                              host: self.selectedHost,
                                                              event: self.selectedEvent)
                }
            }
    }

    
    private func addGuest(eventId: String,
                          status: GuestStatus,
                          invitedBy: String? = nil,
                          checkedInBy: String? = nil) {
        guard let universityId = self.selectedUniversity?.id else { return }
        
        let guest = EventGuest(name: self.name,
                               universityId: universityId,
                               email: self.email,
                               age: self.age,
                               gender: self.gender,
                               status: status,
                               invitedBy: invitedBy,
                               checkedInBy: checkedInBy,
                               timestamp: Timestamp())
        
        guard let encodedGuest = try? Firestore.Encoder().encode(guest) else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .addDocument(data: encodedGuest) { error in
                if let _ = error {
                    self.alertItem = AlertContext.unableToAddGuest
                }
            }
    }
    
    
    @MainActor
    func checkIn() {
        guard let eventId = selectedEvent?.id, let guestId = selectedGuest?.id else { return }
        
        service.checkInUser(eventUid: eventId, uid: guestId) { error in
            if let error = error {
                print("DEBUG: Error checking guest in. \(error.localizedDescription)")
                return
            }
            
            if let updatedGuest = self.guests.first(where: { $0.id == guestId }) {
                self.selectedGuest = updatedGuest
            }
            
            HapticManager.playSuccess()
        }
    }
    
    
    @MainActor
    func remove() {
        guard let selectedGuest = selectedGuest,
              let guestId = selectedGuest.id,
              let eventId = selectedEvent?.id else { return }
        
        if selectedGuest.status == .checkedIn && !self.isShowingUserInfoModal {
            confirmationAlertItem = AlertContext.confirmRemoveMember {
                self.service.removeUserFromGuestlist(with: guestId, eventId: eventId) { _ in }
            }
        } else if selectedGuest.status == .invited || self.isShowingUserInfoModal {
            self.service.removeUserFromGuestlist(with: guestId, eventId: eventId) { _ in
                self.isShowingUserInfoModal = false
            }
        }
    }
    
    
    
}

// MARK: - Helpers for Observing Guestlist
extension GuestlistViewModel {
    private func addGuestlistObserverForEvent() {
        viewState = .loading
        if listener != nil { listener?.remove() }
        guard let selectedEvent = selectedEvent, let eventId = selectedEvent.id else { return }
        
        self.listener = COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let guests = documents.compactMap({ try? $0.data(as: EventGuest.self) })
                
                print("DEBUG: Guests \(guests)")
                self.fetchAndAssignUniversities(to: guests) { updatedGuests in
                    DispatchQueue.main.async {
                        self.guests = updatedGuests
                        self.refreshViewState()
                    }
                }
            }
    }
    
    
    private func fetchAndAssignUniversities(to guests: [EventGuest],
                                            completion: @escaping ([EventGuest]) -> Void) {
        var updatedGuests = guests
        let uniqueUniversityIds = Set(guests.compactMap { $0.universityId }).filter { !$0.isEmpty }

        UserService.shared.fetchUniversities(with: Array(uniqueUniversityIds)) { universities in
            for university in universities {
                print("DEBUG: university \(university.name)")
                for (index, guest) in updatedGuests.enumerated() {
                    if guest.universityId == university.id {
                        updatedGuests[index].university = university
                        print("DEBUG: updated guest \(updatedGuests[index])")
                    }
                }
            }
            completion(updatedGuests)
        }
    }
    
    
    private func updateSectionedGuests() {
        self.sectionedGuests = Dictionary(grouping: guests, by: {
            let name = $0.name
            let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            let firstChar = String(normalizedName.first ?? "z").uppercased()
            return firstChar
        })
    }
}
