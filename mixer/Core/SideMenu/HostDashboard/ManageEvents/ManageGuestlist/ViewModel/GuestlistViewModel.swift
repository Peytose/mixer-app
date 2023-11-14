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
    
    @Published private(set) var guests = [EventGuest]()
    
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
        // If the search text is empty, reset to the full list
        if searchText.isEmpty {
            refreshViewState(with: guests)
        } else {
            // Filter the guests for names that contain the search text
            let filtered = guests.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            // Update your viewState and sectionedGuests accordingly
            refreshViewState(with: filtered)
        }
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
        
        // Return the formatted string with correct singular or plural form
        return "\(totalGuestCount) guest\(totalGuestCount != 1 ? "s" : "")"
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
            .getDocument { snapshot, error in
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
    @MainActor
    func createGuest() {
        guard let eventId = self.event.id,
              let currentUserName = UserService.shared.user?.fullName else { return }
        
        if let guest = self.guests.first(where: { $0.username == username }) {
            switch guest.status {
                case .invited:
                    self.alertItem = AlertContext.duplicateGuestInvite
                case .checkedIn:
                    self.alertItem = AlertContext.guestAlreadyJoined
                case .requested:
                    self.approveGuest(guest)
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
    
    
    func approveGuest(_ guest: EventGuest) {
        guard let guestId = guest.id,
              let host = UserService.shared.user?.currentHost else { return }
        
        self.hostService.approveGuest(with: guestId,
                                  for: self.event,
                                  by: host) { error in
            if let error = error {
                print("DEBUG: Error approving guest. \(error.localizedDescription)")
                return
            }
            
            if let updatedGuest = self.guests.first(where: { $0.id == guestId }) {
                self.selectedGuest = updatedGuest
            }
            
            HapticManager.playSuccess()
        }
    }

    
    private func fetchUserAndAddToGuestlist(eventId: String,
                                            status: GuestStatus,
                                            invitedBy: String? = nil,
                                            checkedInBy: String? = nil) {
        guard let host = self.userService.user?.currentHost else { return }
        
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
        let age = isTwentyOnePlus ? 21 : 20

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
        guard let eventId = self.event.id, let guestId = selectedGuest?.id else { return }
        
        hostService.checkInUser(eventId: eventId, uid: guestId) { error in
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
        
        if selectedGuest.status == .checkedIn && !self.isShowingUserInfoModal {
            confirmationAlertItem = AlertContext.confirmRemoveMember {
                self.hostService.removeUserFromGuestlist(with: guestId, eventId: eventId) { _ in }
            }
        } else if selectedGuest.status == .invited || selectedGuest.status == .requested || self.isShowingUserInfoModal {
            self.hostService.removeUserFromGuestlist(with: guestId, eventId: eventId) { _ in
                self.isShowingUserInfoModal = false
            }
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



import Foundation

extension GuestlistViewModel {
    func tt_upload() {
        if let fileURL = Bundle.main.url(forResource: "test_guestlist", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: fileURL)
                
                // Decode into an array of dictionaries
                let decodedArray = try JSONDecoder().decode([[String: String]].self, from: jsonData)
                
                // Transform the array into the desired dictionary format
                var inviteeDict = [String: [String]]()
                for entry in decodedArray {
                    let brotherName = entry["Brother"]!
                    let invitees = Array(entry.values).filter { $0 != brotherName }
                    inviteeDict[brotherName] = invitees
                }
                
                // Now you have a dictionary with the brother's name as the key and the list of invitees as the value.
                self.uploadGuestsFromDict(guestDict: inviteeDict)
            } catch {
                print("Failed to read or decode JSON: \(error)")
            }
        } else {
            print("Failed to find test_guestlist.json in the main bundle.")
        }
    }
    
    
    func uploadGuestsFromDict(guestDict: [String: [String]]) {
        for (brotherName, invitees) in guestDict {
            for invitee in invitees where !invitee.isEmpty {
                uploadSingleGuest(invitee: invitee, brotherName: brotherName)
            }
        }
    }
    
    func uploadSingleGuest(invitee: String, brotherName: String) {
        var cleanedInvitee = invitee  // This will store the name without any notes or "+x" patterns.
        var fullNote: String?
        
        // Extract gender.
        let gender = inferGenderFromName(cleanedInvitee)
        
        // Extract note within parentheses
        if let leftParenIndex = cleanedInvitee.firstIndex(of: "("), let rightParenIndex = cleanedInvitee.firstIndex(of: ")") {
            let noteWithinParens = String(cleanedInvitee[leftParenIndex...rightParenIndex])
            cleanedInvitee = cleanedInvitee.replacingOccurrences(of: noteWithinParens, with: "").trimmingCharacters(in: .whitespaces)
            fullNote = String(noteWithinParens.dropFirst().dropLast()) // Convert to String after removing parentheses
        }
        
        // Extract "+<number>" patterns (with potential space) indicating additional guests
        if let range = cleanedInvitee.range(of: "\\+\\s?\\d", options: .regularExpression) {
            let plusGuests = String(cleanedInvitee[range])
            cleanedInvitee = cleanedInvitee.replacingOccurrences(of: plusGuests, with: "").trimmingCharacters(in: .whitespaces)
            fullNote = (fullNote == nil) ? plusGuests : "\(fullNote!), \(plusGuests) additional guests"
        }
        
        let guest = EventGuest(name: cleanedInvitee,
                               universityId: "com",
                               note: fullNote,
                               gender: gender,
                               status: .invited,
                               invitedBy: brotherName,
                               timestamp: Timestamp())
        
        guard let encodedGuest = try? Firestore.Encoder().encode(guest) else { return }
        
        let docId = "oo9xPo97lxtqcErh9wo8"
        COLLECTION_EVENTS
            .document(docId)
            .collection("guestlist")
            .addDocument(data: encodedGuest) { error in
                if let error = error {
                    print("DEBUG: Error \(error.localizedDescription)")
                    return
                }
            }
    }
    
    func inferGenderFromName(_ name: String) -> Gender {
        // Lists based on common names and the provided data
        let maleNames = ["Ben", "Matt", "Phillip", "Colin", "Steven", "Alexander"]
        let femaleNames = ["Cristina", "Leah", "Maddie", "Cindy", "Sophie", "Samantha", "Alexandria", "Emma"]
        
        let cleanName = name.components(separatedBy: " ")[0]
        
        if maleNames.contains(cleanName) {
            return .man
        } else if femaleNames.contains(cleanName) {
            return .woman
        } else {
            return .preferNotToSay
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

