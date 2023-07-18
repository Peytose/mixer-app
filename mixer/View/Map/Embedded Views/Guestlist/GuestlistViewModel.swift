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

final class GuestlistViewModel: ObservableObject {
    @Published var guests = [EventGuest]()
    @Published var sectionDictionary: [String: [EventGuest]] = [:]
    @Published var isShowingUserInfoModal: Bool = false
    @Published var isShowingQRCodeScanView: Bool = false
    @Published var alertItem: AlertItem?
    @Published var alertItemTwo: AlertItemTwo?
    @Published var selectedGuest: EventGuest?
    @Published var events: [CachedEvent] = []
    @Published var currentEvent: CachedEvent? {
        didSet {
            self.fetchGuestlistForCurrentEvent()
        }
    }
    
    @Published var currentHost: CachedHost? {
        didSet {
            self.fetchEventsForCurrentHost()
        }
    }
    
    let hostEventsDict: [CachedHost: [CachedEvent]]
    
    init(hostEventsDict: [CachedHost: [CachedEvent]]) {
        self.hostEventsDict = hostEventsDict
        self.currentHost = hostEventsDict.keys.first
    }
}


// Helpers for data fetch and processing
extension GuestlistViewModel {
    // Fetch all data for the current host and their events
    private func fetchEventsForCurrentHost() {
        guard let currentHost = currentHost else { return }
        
        if let events = hostEventsDict[currentHost] {
            self.events = events
        }
        
        self.currentEvent = self.events.first
    }
    
    
    // Fetch all guests for the current event
    private func fetchGuestlistForCurrentEvent() {
        guard let currentEvent = currentEvent, let eventId = currentEvent.id else { return }
        let query = COLLECTION_EVENTS.document(eventId).collection("attendance-list")
        
        query.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.guests = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: EventGuest.self)
            }
            
            self.sectionDictionary = self.getSectionedDictionary()
        }
    }
    
    
    // Returns a dictionary grouping the guests
    private func getSectionedDictionary() -> Dictionary<String, [EventGuest]> {
        let sectionDictionary: Dictionary<String, [EventGuest]> = {
            return Dictionary(grouping: guests, by: {
                let name = $0.name
                let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                let firstChar = String(normalizedName.first ?? "z").uppercased()
                return firstChar
            })
        }()
        
        return sectionDictionary
    }
    
    
    // If search text is available, filter guests
    func filterGuests(with searchText: String) {
        guard !searchText.isEmpty else { return }
        
        let filteredGuests = guests.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
        
        guests = filteredGuests
        sectionDictionary = getSectionedDictionary()
    }
}

// Helpers for CRUD operations on guests
extension GuestlistViewModel {
    // Create a new guest
    @MainActor func createGuest(username: String, name: String, university: String, status: GuestStatus, age: Int?, gender: String) {
        guard let currentEventId = currentEvent?.id,
              let currentUserName = AuthViewModel.shared.currentUser?.name else { return }
        
        if username != "" {
            Task {
                let user = try await UserCache.shared.getUser(from: username)
                
                HostService.addUserToGuestlist(eventUid: currentEventId, user: user, invitedBy: currentUserName) { _ in
                    self.refreshGuests()
                }
            }
        } else {
            let newGuest = EventGuest(name: name,
                                      university: university,
                                      age: age,
                                      gender: gender,
                                      status: status,
                                      invitedBy: currentUserName,
                                      timestamp: Timestamp())
            
            let data = newGuest.toDictionary()
            
            COLLECTION_EVENTS.document(currentEventId).collection("attendance-list").addDocument(data: data) { error in
                if let _ = error {
                    self.alertItem = AlertContext.unableToAddGuest
                    return
                }
                
                self.guests.append(newGuest)
                self.sectionDictionary = self.getSectionedDictionary()
            }
        }
    }
    
    
    // Remove an existing guest
    @MainActor func remove(guest: EventGuest) {
        guard let guestId = guest.id,
              let currentEventId = currentEvent?.id else { return }
        
        if guest.status == .checkedIn && !self.isShowingUserInfoModal {
            alertItemTwo = AlertContext.guestAlreadyCheckedIn {
                COLLECTION_EVENTS.document(currentEventId).collection("attendance-list").document(guestId).delete { _ in
                    self.guests.removeAll(where: { $0.id == guestId })
                    self.sectionDictionary = self.getSectionedDictionary()
                }
            }
        } else if guest.status == .invited || self.isShowingUserInfoModal {
            COLLECTION_EVENTS.document(currentEventId).collection("attendance-list").document(guestId).delete { _ in
                self.guests.removeAll(where: { $0.id == guestId })
                self.sectionDictionary = self.getSectionedDictionary()
                
                if self.isShowingUserInfoModal {
                    self.isShowingUserInfoModal = false
                }
            }
        }
    }
    
    
    // Update a guest's status to 'isCheckedIn'
    @MainActor func checkIn(guest: EventGuest) {
        guard let currentUserName = AuthViewModel.shared.currentUser?.name,
              let currentEventId = currentEvent?.id,
              let guestId = guest.id else { return }
        
        self.selectedGuest = guest
        
        HostService.checkInUser(eventUid: currentEventId, uid: guestId, checkedInBy: currentUserName) { error in
            if let error = error {
                print("DEBUG: Error checking guest in. \(error.localizedDescription)")
                return
            }
            
            self.selectedGuest?.status      = .checkedIn
            self.selectedGuest?.checkedInBy = currentUserName
            self.selectedGuest?.timestamp   = Timestamp()
            
            if let index = self.guests.firstIndex(where: { $0.id == guestId }) {
                self.guests[index].status = .checkedIn
                self.sectionDictionary = self.getSectionedDictionary()
            }
            
            HapticManager.playSuccess()
        }
    }
}

// Helpers for handling events and hosts
extension GuestlistViewModel {
    // Change the current event to a new one
    func changeEvent(to event: CachedEvent) {
        self.currentEvent = event
    }
    
    
    // Refresh all guests for the current event
    @MainActor func refreshGuests() {
        guard let currentEventId = currentEvent?.id else { return }
        
        EventLists.loadUsers(eventUid: currentEventId) { users in
            self.guests = users
            self.sectionDictionary = self.getSectionedDictionary()
            print("DEBUG: Refreshed guestlist!")
        }
    }
}

// Helpers for handling QR code scanning
extension GuestlistViewModel {
    // Handle the scanning process
    @MainActor func handleScan(_ response: Result<ScanResult, ScanError>) {
        self.isShowingQRCodeScanView = false
        switch response {
        case .success(let result):
            self.handleScannedUser(result)
        case .failure(let error):
            print("DEBUG: Scanning failed due to \(error.localizedDescription)")
        }
    }
    
    
    // Handle a scanned user
    @MainActor private func handleScannedUser(_ result: ScanResult) {
        let uid = result.string
        
        guard uid.count <= 128, uid.range(of: "\\W", options: .regularExpression) == nil else {
            print("DEBUG: QR code data is not a valid DocumentID.")
            return
        }
        
        guard let isInviteOnly = currentEvent?.eventOptions["isInviteOnly"] else { return }
        
        if isInviteOnly {
            if let guest = guests.first(where: { $0.id == uid }) {
                self.checkIn(guest: guest)
            } else {
                print("DEBUG: User is not on guestlist")
            }
        } else {
            Task {
                let user = try await UserCache.shared.getUser(withId: uid)
                guard let eventId = currentEvent?.id else { return }
                
                if let guest = guests.first(where: { $0.id == uid }) {
                    self.checkIn(guest: guest)
                } else {
                    HostService.addUserToGuestlist(eventUid: eventId, user: user) { _ in
                        self.refreshGuests()
                        
                        if let guest = self.guests.first(where: { $0.id == uid }) {
                            self.checkIn(guest: guest)
                        }
                    }
                }
            }
        }
    }
}
