//
//  GuestlistViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import CodeScanner

struct SmartSearchMatcher {
    public init(searchString: String) {
        searchTokens = searchString.split(whereSeparator: { $0.isWhitespace }).sorted { $0.count > $1.count }
    }
        
    func matches(_ candidateString: String) -> Bool {
        guard !searchTokens.isEmpty else { return true }
        var candidateStringTokens = candidateString.split(whereSeparator: { $0.isWhitespace })
        for searchToken in searchTokens {
            var matchedSearchToken = false
            for (candidateStringTokenIndex, candidateStringToken) in candidateStringTokens.enumerated () {
                if let range = candidateStringToken.range(of: searchToken, options: [.caseInsensitive, .diacriticInsensitive]),
                   range.lowerBound == candidateStringToken.startIndex {
                    matchedSearchToken = true
                    candidateStringTokens.remove(at: candidateStringTokenIndex)
                    break
                }
            }
            guard matchedSearchToken else { return false }
        }
        return true
    }
        private(set) var searchTokens: [String.SubSequence]
}

class GuestlistViewModel: ObservableObject {
    @Published private(set) var sectionedGuests: [String: [EventGuest]] = [:]
    @Published var selectedGuestSection: GuestStatus = .invited {
        didSet {
            refreshViewState(with: self.guests)
        }
    }
    @Published var selectedGuest: EventGuest?
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
    
    @Published var event: Event
    @Published var viewState: ListViewState = .empty
    @Published var isShowingUserInfoModal = false
    @Published var username               = ""
    @Published var name                   = ""
    @Published var email                  = ""
    @Published var selectedUniversity: University?
    @Published var universityName         = ""
    @Published var note                   = ""
    @Published var status                 = GuestStatus.invited
    @Published var gender                 = Gender.man
    @Published var age                    = 18
    @Published var isWithoutUniversity: Bool    = false
    
    @Published private(set) var guests = [EventGuest]()
    private var universityIdDict = [String:String]()
    
    private let userService = UserService.shared
    private let hostService = HostService.shared
    private var listener: ListenerRegistration?
    
    init(event: Event) {
        self.event = event
        self.addGuestlistObserverForEvent()
        print("DEBUG: Initialized guestlist!!")
    }
    
    deinit {
        listener?.remove()
    }
    
    
    private func refreshViewState(with guests: [EventGuest]) {
        let statusFilteredGuests = guests.filter({ $0.status == selectedGuestSection })
        let sortedGuests = statusFilteredGuests.sorted(by: { $0.name < $1.name })
        self.viewState = sortedGuests.isEmpty ? .empty : .list
        
        updateSectionedGuests(sortedGuests)
    }
    
    
    func filterGuests(for searchText: String) -> [EventGuest] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedSearchText.isEmpty else { return [] }
        
        let smartSearchMatcher = SmartSearchMatcher(searchString: trimmedSearchText)
        
        let filtered = sectionedGuests.values.flatMap({ $0 }).filter { guest in
            let searchableName = guest.name.folding(options: .diacriticInsensitive, locale: .current)
            return smartSearchMatcher.matches(searchableName)
        }
        
        return filtered
    }
    
    
    func getPdfTitle() -> String {
        let purpose = "Attendance"
        let date = Timestamp().getTimestampString(format: "yyyy-MM-dd")
        let time = Timestamp().getTimestampString(format: "HHmm")

        return "\(self.event.title)_\(purpose)_\(date)_\(time)"
    }
    
    
    func getGuestlistSectionCountText() -> String {
        // Calculate the total count of guests by summing up the counts of each section's array
        let totalGuestCount = self.sectionedGuests.values.reduce(0) { $0 + $1.count }
        let countTitle = selectedGuestSection.guestlistSectionTitle
        
        return "\(countTitle): \(totalGuestCount)"
    }
    
    
    func getGenderRatioText() -> String {
        let maleCount = self.guests.filter { $0.gender == .man }.count
        let femaleCount = self.guests.filter { $0.gender == .woman }.count

        // Avoid division by zero by checking if there are any men
        if maleCount == 0 {
            return femaleCount == 0 ? "No guests" : "All women"
        } else {
            // Calculate the ratio of women per man as a floating-point number for precision
            let ratio = Float(femaleCount) / Float(maleCount)
            
            // Format the ratio to have one decimal point for readability
            return String(format: "%.1f women per man", ratio)
        }
    }

    
    private func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        if b == 0 {
            return a
        } else {
            return greatestCommonDivisor(b, a % b)
        }
    }
    
    
    func selectUniversity(_ university: University) {
        self.selectedUniversity = university
        self.universityName     = university.name
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
        
        if let guest = guests.first(where: { $0.id == uid }), guest.status != .checkedIn {
            self.selectedGuest = guest
            self.checkIn()
        } else if !self.event.isInviteOnly {
            let status: GuestStatus = self.event.startDate > Timestamp() ? .invited : .checkedIn
            fetchAndAddUserToGuestlist(uid: uid, status: status)
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.confirmationAlertItem = AlertContext.addGuestToInviteOnly {
                    let status: GuestStatus = self.event.startDate > Timestamp() ? .invited : .checkedIn
                    self.fetchAndAddUserToGuestlist(uid: uid, status: status)
                }
            }
        }
    }
    
    
    @MainActor
    private func fetchAndAddUserToGuestlist(uid: String, status: GuestStatus) {
        guard let host = self.userService.user?.currentHost else { return }
        
        COLLECTION_USERS
            .document(uid)
            .fetchWithCachePriority(freshnessDuration: 7200) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching user. \(error.localizedDescription)")
                    return
                }
                
                guard let user = try? snapshot?.data(as: User.self),
                      let eventId = self.event.id,
                      let userId = user.id else { return }
                
                self.hostService.addUserToGuestlist(eventId: eventId,
                                                    user: user,
                                                    status: status) { error in
                    if let error = error {
                        print("DEBUG: Error adding user to guestlist. \(error.localizedDescription)")
                        return
                    }
                    
                    self.username = ""
                    
                    NotificationsViewModel.uploadNotification(toUid: userId,
                                                              type: .guestlistAdded,
                                                              host: host,
                                                              event: self.event)
                }
            }
    }
}

// MARK: - CRUD Operations on Guests
extension GuestlistViewModel {
    func saveNote(_ note: String) {
        self.note = note
    }
    
    
    @MainActor
    func createGuest() {
        guard let eventId = self.event.id,
              let currentUsername = UserService.shared.user?.username else { return }
        
        self.selectedGuest = self.guests.first(where: { $0.username == username })
        
        if let guest = selectedGuest {
            switch guest.status {
                case .invited:
                    self.alertItem = AlertContext.duplicateGuestInvite
                case .checkedIn:
                    self.alertItem = AlertContext.guestAlreadyJoined
                case .requested:
                    self.approveGuest()
            }
        } else {
            if username != "" {
                self.fetchUserAndAddToGuestlist(eventId: eventId,
                                                status: self.status,
                                                invitedBy: currentUsername)
            } else {
                self.addGuest(eventId: eventId,
                              status: self.status,
                              invitedBy: currentUsername)
            }
        }
    }
    
    
    func approveGuest() {
        print("DEBUG: Starting to approve guest...")

        guard let guestId = selectedGuest?.id else {
            print("DEBUG: Failed to retrieve selected guest ID.")
            return
        }
        print("DEBUG: Selected guest ID: \(guestId)")

        guard let host = UserService.shared.user?.currentHost else {
            print("DEBUG: Failed to retrieve current host from user service.")
            return
        }
        print("DEBUG: Current host: \(host.name)")

        guard let eventId = event.id else {
            print("DEBUG: Failed to retrieve event ID.")
            return
        }
        print("DEBUG: Event ID: \(eventId)")

        print("DEBUG: Attempting to approve guest with ID \(guestId) for event \(eventId) by host \(host.name)...")

        self.hostService.approveGuest(with: guestId, for: self.event, by: host) { error in
            if let error = error {
                print("DEBUG: Error approving guest. \(error.localizedDescription)")
                return
            }
            
            print("DEBUG: Guest approved successfully.")
            
            if let updatedGuest = self.guests.first(where: { $0.id == guestId }) {
                print("DEBUG: Updated guest: \(updatedGuest.name)")
                self.selectedGuest = updatedGuest
            } else {
                print("DEBUG: Failed to find updated guest in the list.")
            }
            
            if self.event.isPrivate && self.event.isInviteOnly {
                print("DEBUG: Event is private and invite-only. Adding event to accessible events for guest \(guestId)...")
                COLLECTION_USERS
                    .document(guestId)
                    .collection("accessible-events")
                    .document(eventId)
                    .setData(["timestamp": Timestamp(),
                              "hostIds": self.event.hostIds]) { error in
                        if let error = error {
                            print("DEBUG: Error adding event to user-specific collection: \(error.localizedDescription)")
                            return
                        }
                        print("DEBUG: Added event to guest's list.")
                        HapticManager.playSuccess()
                    }
            } else {
                print("DEBUG: Event is not private and invite-only, proceeding to play success haptic.")
                HapticManager.playSuccess()
            }
        }
    }


    
    private func fetchUserAndAddToGuestlist(eventId: String,
                                            status: GuestStatus,
                                            invitedBy: String? = nil,
                                            checkedInBy: String? = nil) {
        guard let host = self.userService.user?.currentHost else { return }
        let queryKey = QueryKey(collectionPath: "users",
                                filters: ["username == \(username)"],
                                limit: 1)
        
        COLLECTION_USERS
            .whereField("username", isEqualTo: self.username)
            .limit(to: 1)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 7200) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting user from username: \(error.localizedDescription)")
                    return
                }
                
                guard let user = try? snapshot?.documents.first?.data(as: User.self),
                      let userId = user.id else { return }
                
                self.hostService.addUserToGuestlist(eventId: eventId,
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
                                                              host: host,
                                                              event: self.event)
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
                               note: self.note.isEmpty ? nil : self.note,
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
        guard let eventId = self.event.id,
              let guest = selectedGuest,
              let guestId = guest.id else { return }
        
        hostService.checkIn(guest: guest, eventId: eventId) { error in
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
              let eventId = self.event.id else { return }
        
        if selectedGuest.status == .checkedIn && self.isShowingUserInfoModal {
            self.isShowingUserInfoModal = false
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.confirmationAlertItem = AlertContext.confirmRemoveMember {
                    self.hostService.removeUserFromGuestlist(with: guestId, eventId: eventId) { _ in }
                }
            }
        } else {
            self.hostService.removeUserFromGuestlist(with: guestId, eventId: eventId) { _ in }
        }
    }
}

// MARK: - Helpers for Observing Guestlist
extension GuestlistViewModel {
    private func addGuestlistObserverForEvent() {
        if listener != nil { listener?.remove() }
        
        guard let eventId = self.event.id else { return }
        
        viewState = .loading
        self.listener = COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("DEBUG: Error adding snapshot listener to guestlist.\n\(error.localizedDescription)")
                    self.viewState = .empty
                    return
                }
                
                guard let documents = snapshot?.documents else { return}
                let guests = documents.compactMap({ try? $0.data(as: EventGuest.self) })
                
                if guests.isEmpty {
                    self.viewState = .empty
                    return
                }
                
                self.fetchAndAssignUniversities(to: guests) { updatedGuests in
                    DispatchQueue.main.async {
                        self.guests = updatedGuests
                        self.refreshViewState(with: updatedGuests)
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
                for (index, guest) in updatedGuests.enumerated() {
                    if guest.universityId == university.id {
                        updatedGuests[index].university = university
                    }
                }
            }
            completion(updatedGuests)
        }
    }
    
    
    private func updateSectionedGuests(_ guests: [EventGuest]) {
        self.sectionedGuests = Dictionary(grouping: guests, by: {
            let name = $0.name
            let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            let firstChar = String(normalizedName.first ?? "z").uppercased()
            return firstChar
        })
    }
}
