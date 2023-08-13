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
    @Published var currentEvent: Event? {
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
    @Published private(set) var sectionedGuests: [String: [EventGuest]] = [:]

    @Published var selectedGuest: EventGuest?
    @Published var alertItem: AlertItem?
    @Published var confirmationAlertItem: ConfirmationAlertItem?

    @Published var isShowingUserInfoModal = false
    @Published var username               = ""
    @Published var name                   = ""
    @Published var customUniversity       = ""
    @Published var university             = UniversityExamples.mit
    @Published var status                 = GuestStatus.invited
    @Published var gender                 = Gender.man
    @Published var age                    = 18

    private let service = HostService.shared
    private var listener: ListenerRegistration?
    
    init(events: [Event]) {
        self.currentEvent = events.first
    }
    
    deinit {
        listener?.remove()
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
        self.currentEvent = event
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
        
        guard let currentEvent = currentEvent else { return }
        
        if let guest = guests.first(where: { $0.id == uid }) {
            self.selectedGuest = guest
            self.checkIn()
        } else if !currentEvent.isInviteOnly {
            fetchAndAddUserToGuestlist(uid: uid)
        } else {
            print("DEBUG: User is not on guestlist")
        }
    }
    
    
    @MainActor
    private func fetchAndAddUserToGuestlist(uid: String) {
        COLLECTION_USERS
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error checking user in. \(error.localizedDescription)")
                    return
                }
                
                guard let user = try? snapshot?.data(as: User.self), let eventId = self.currentEvent?.id else { return }
                self.service.addUserToGuestlist(eventUid: eventId, user: user) { _ in
                    if let guest = self.guests.first(where: { $0.id == uid }) {
                        self.selectedGuest = guest
                        self.checkIn()
                    }
                }
            }
    }
}

// MARK: - CRUD Operations on Guests
extension GuestlistViewModel {
    @MainActor
    func createGuest() {
        guard let eventId = currentEvent?.id, let currentUserName = AuthViewModel.shared.currentUser?.name else { return }
        
        if username != "" {
            self.fetchUserAndAddToGuestlist(eventId: eventId, invitedBy: currentUserName)
        } else {
            self.addGuest(eventId: eventId, invitedBy: currentUserName)
        }
    }

    
    private func fetchUserAndAddToGuestlist(eventId: String, invitedBy: String) {
        COLLECTION_USERS
            .whereField("username", isEqualTo: self.username)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting user from username: \(error.localizedDescription)")
                    return
                }
                
                guard let user = try? snapshot?.documents.first?.data(as: User.self) else { return }
                
                self.service.addUserToGuestlist(eventUid: eventId, user: user, invitedBy: invitedBy) { error in
                    if let _ = error {
                        self.alertItem = AlertContext.unableToAddGuest
                    }
                }
            }
    }

    
    private func addGuest(eventId: String, invitedBy: String) {
        let guest = EventGuest(name: name,
                               university: university.rawValue,
                               age: age,
                               gender: gender,
                               status: status,
                               invitedBy: invitedBy,
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
        guard let eventId = currentEvent?.id, let guestId = selectedGuest?.id else { return }
        
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
        guard let selectedGuest = selectedGuest, let guestId = selectedGuest.id, let eventId = currentEvent?.id else { return }

        if selectedGuest.status == .checkedIn && !self.isShowingUserInfoModal {
            confirmationAlertItem = AlertContext.guestAlreadyCheckedIn {
                self.removeGuest(with: guestId, eventId: eventId)
            }
        } else if selectedGuest.status == .invited || self.isShowingUserInfoModal {
            self.removeGuest(with: guestId, eventId: eventId)
        }
    }
    
    
    private func removeGuest(with id: String, eventId: String) {
        COLLECTION_EVENTS.document(eventId).collection("guestlist").document(id).delete { _ in
            if self.isShowingUserInfoModal {
                self.isShowingUserInfoModal = false
            }
        }
    }
}

// MARK: - Helpers for Observing Guestlist
extension GuestlistViewModel {
    private func addGuestlistObserverForEvent() {
        if listener != nil { listener?.remove() }
        guard let currentEvent = currentEvent, let eventId = currentEvent.id else { return }
        
        self.listener = COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self.guests = documents.compactMap({ try? $0.data(as: EventGuest.self) })
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
