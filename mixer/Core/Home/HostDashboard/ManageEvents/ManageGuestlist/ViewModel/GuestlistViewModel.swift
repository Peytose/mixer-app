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
    
    
    func filterGuests(for searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedSearchText.isEmpty else {
            refreshViewState(with: guests)
            return
        }

        // Split the search text into words for flexible matching
        let searchWords = trimmedSearchText.split(separator: " ").map(String.init)

        let filtered = guests.filter { guest in
            // Check if each word in the search text is contained in the guest name
            let guestNameLowercased = guest.name.lowercased()
            return searchWords.allSatisfy { searchWord in
                guestNameLowercased.contains(searchWord)
            }
        }

        refreshViewState(with: filtered)
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
            print("DEBUG: User is not on guestlist")
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
    
    
    func uploadGuestlistJSON() {
        print("DEBUG: Uploading json guestlist... ")
        let eventId = ""
        
        guard let fileURL = Bundle.main.url(forResource: "guestlist", withExtension: "json") else {
            print("File URL not found")
            return
        }

        do {
            let jsonData = try Data(contentsOf: fileURL)
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: String]] {
                for guestDict in jsonArray {
                    print("DEBUG: Guest dict: \(guestDict)")
                    processAndUploadGuest(guestDict, forEvent: eventId)
                }
            }
        } catch {
            print("Error reading or parsing JSON: \(error)")
        }
    }

    private func processAndUploadGuest(_ guestDict: [String: String], forEvent eventId: String) {
        guard let nameField = guestDict["Name"],
              let schoolShortName = guestDict["School"],
              let invitedBy = guestDict["Brother"] else { return }

        let isTwentyOnePlus = (guestDict["21+"] != "N")
        let age = isTwentyOnePlus ? 21 : 19

        let names = nameField.components(separatedBy: "\n")
        for name in names {
            uploadGuestWithName(name, schoolShortName: schoolShortName, age: age, invitedBy: invitedBy, forEvent: eventId)
        }
    }

    private func uploadGuestWithName(_ name: String, schoolShortName: String, age: Int, invitedBy: String, forEvent eventId: String) {
        UserService.shared.fetchUniversityId(for: schoolShortName) { universityId in
            let guest = EventGuest(name: name.trimmingCharacters(in: .whitespacesAndNewlines).capitalized,
                                   universityId: universityId,
                                   age: age,
                                   gender: .preferNotToSay,  // Replace with actual gender if available
                                   status: .invited,  // Replace with appropriate status if different
                                   invitedBy: invitedBy,
                                   timestamp: Timestamp())

            guard let encodedGuest = try? Firestore.Encoder().encode(guest) else { return }
            
            COLLECTION_EVENTS
                .document(eventId)
                .collection("guestlist")
                .addDocument(data: encodedGuest) { error in
                    if let error = error {
                        print("Error uploading guest: \(error.localizedDescription)")
                    }
                    
                    print("DEBUG: UPLOADED GUESTS!")
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
            
            // MARK: Last bug - couldn't get notification to pop up
//            confirmationAlertItem = AlertContext.confirmRemoveMember {
                self.hostService.removeUserFromGuestlist(with: guestId, eventId: eventId) { _ in }
//            }
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


extension GuestlistViewModel {
    @MainActor
    func uploadManualGuestlist() {
        if let fileURL = Bundle.main.url(forResource: "valentines-guestlist", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: fileURL)
                let decodedArray = try JSONDecoder().decode([[String: String]].self, from: jsonData)

                var universitySet = Set<String>()

                for guestDict in decodedArray {
                    if let universityStr = guestDict["University"] {
                        if universityStr == "" {
                            universitySet.insert("Non-university")
                        } else {
                            universitySet.insert(universityStr)
                        }
                    }
                }

                let dispatchGroup = DispatchGroup()
                print("Starting to fetch university IDs for \(universitySet)...")

                for name in universitySet {
                    dispatchGroup.enter()
                    
                    userService.fetchUniversityId(for: name) { id in
                        print("Fetched ID for \(name): \(id)")
                        self.universityIdDict[name] = id
                        dispatchGroup.leave()
                    }
                }

                print("Set up dispatch group notify...")
                dispatchGroup.notify(queue: .main) {
                    print("All university IDs fetched, starting to upload guests...")
                    self.uploadGuestsFromDict(guestArray: decodedArray)
                }
            } catch {
                print("Failed to read or decode JSON: \(error)")
            }
        } else {
            print("Failed to find test_guestlist.json in the main bundle.")
        }
    }

    
    
    func uploadGuestsFromDict(guestArray: [[String:String]]) {
        for guestDict in guestArray {
            uploadSingleGuest(guestDict: guestDict)
        }
    }
    
    func uploadSingleGuest(guestDict: [String:String]) {
        let name            = guestDict["Name"]!
        let genderStr       = guestDict["Gender"]!
        let universityStr   = guestDict["University"]!
        let brotherFullName = guestDict["Brother"]!
        let gender          = determineGender(genderStr)
        
        var guest = EventGuest(name: name,
                               universityId: (universityIdDict[universityStr] ?? "com"),
                               age: guestDict["21+"] == "N" ? 19 : 21,
                               gender: gender,
                               status: .invited,
                               invitedBy: brotherFullName,
                               timestamp: Timestamp())
        
        guard let encodedGuest = try? Firestore.Encoder().encode(guest) else { return }
        print("\(encodedGuest)\n")
//        let docId = "Sab0cQkG2jTm772WTbny"
//        
//        COLLECTION_EVENTS
//            .document(docId)
//            .collection("guestlist")
//            .addDocument(data: encodedGuest) { error in
//                if let error = error {
//                    print("DEBUG: Error \(error.localizedDescription)")
//                    return
//                }
//                
//                print("DEBUG: \(guest.name) added!")
//            }
    }
    
    func determineGender(_ letter: String) -> Gender {
        switch letter.lowercased() {
            case "m": return .man
            case "f": return .woman
            default: return .preferNotToSay
        }
    }
    
    func extractNoteFromInvitee(_ invitee: String) -> String? {
        var note: String? = nil
        var plusGuests: String? = nil
        
        // Extract notes within parentheses
        if let leftParenIndex = invitee.firstIndex(of: "("), let rightParenIndex = invitee.firstIndex(of: ")") {
            note = String(invitee[leftParenIndex...rightParenIndex].dropFirst().dropLast())
        }
        
        // Extract "+<number>" patterns (with potential space) indicating additional guests
        if let range = invitee.range(of: "\\+\\s?\\d", options: .regularExpression) {
            plusGuests = String(invitee[range]).replacingOccurrences(of: " ", with: "")  // Remove space for uniformity
            if let existingNote = note {
                note = "\(existingNote), \(plusGuests!) additional guests"
            } else {
                note = "\(plusGuests!) additional guests"
            }
        }
        
        return note
    }
}

