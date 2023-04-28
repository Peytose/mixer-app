//
//  GuestlistViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

final class GuestlistViewModel: ObservableObject {
    @Published var guests = [EventGuest]()
    @Published var sectionDictionary: [String: [EventGuest]] = [:]
    @Published var showUserInfoModal: Bool = false
    @Published var alertItem: AlertItem?
    @Published var alertItemTwo: AlertItemTwo?
    @Published var selectedGuest: EventGuest?
    let event: CachedEvent
    let eventUid: String
    
    init(event: CachedEvent) {
        self.event = event
        self.eventUid = event.id ?? ""

        if let eventId = event.id {
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
    }
    
    
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
    
    
    @MainActor func remove(guest: EventGuest) {
        guard let guestId = guest.id else {
//            completion(true)
            return
        }
        
        if guest.status == .checkedIn && !self.showUserInfoModal {
            alertItemTwo = AlertContext.guestAlreadyCheckedIn {
                COLLECTION_EVENTS.document(self.eventUid).collection("attendance-list").document(guestId).delete { _ in
//                    COLLECTION_USERS.document(guestId).collection("events-attended").document(self.eventUid).delete {
                    self.guests.removeAll(where: { $0.id == guestId })
                    self.sectionDictionary = self.getSectionedDictionary()
//                    }
                }
            }
        } else if guest.status == .invited || self.showUserInfoModal {
            COLLECTION_EVENTS.document(eventUid).collection("attendance-list").document(guestId).delete { _ in
                self.guests.removeAll(where: { $0.id == guestId })
                self.sectionDictionary = self.getSectionedDictionary()
                
                if self.showUserInfoModal {
                    self.showUserInfoModal = false
                }
            }
        }
    }
    
    @MainActor func createGuest(name: String, university: String, status: GuestStatus, age: Int, gender: String) {
        guard let currentUsername = AuthViewModel.shared.currentUser?.name else { return }
        
        let data = ["name": name,
                    "university": university,
                    "age": age,
                    "gender": gender,
                    "status": status.rawValue,
                    "invitedBy": currentUsername,
                    "timestamp": Timestamp()] as [String: Any]
        
        print("DEBUG: Create guest data: \(data)")
        
        COLLECTION_EVENTS.document(self.eventUid).collection("attendance-list").addDocument(data: data) { error in
            if let error = error {
                print("DEBUG: Error adding guest to attendance list. \(error)")
                print("DEBUG: Error adding guest to attendance list. \(error.localizedDescription)")
            }
            
            // Create a new guest from the data and add it to the guests array
            let newGuest = EventGuest(name: name,
                                      university: university,
                                      age: age,
                                      gender: gender,
                                      status: status,
                                      invitedBy: currentUsername,
                                      timestamp: Timestamp())
            
            self.guests.append(newGuest)
            self.sectionDictionary = self.getSectionedDictionary()
            print("DEBUG: guests aftering adding \(name): \(self.guests)")
        }
    }
    
    @MainActor func checkIn(guest: inout EventGuest) {
        guard let guestId = guest.id else { return }
        guard let currentUserName = AuthViewModel.shared.currentUser?.name else { return }
        
        HostService.checkInUser(eventUid: eventUid, uid: guestId, currentUserName: currentUserName) { error in
            if let error = error {
                print("DEBUG: Error checking guest in. \(error.localizedDescription)")
//                self.alertItem = AlertContext.unableToCheck
                return
            }
            
            if let index = self.guests.firstIndex(where: { $0.id == guestId }) {
                self.guests[index].status = .checkedIn // Update the guests array with the updated guest
                self.sectionDictionary = self.getSectionedDictionary()
            }
            
            HapticManager.playSuccess()
        }
        
        guest.status = .checkedIn // Update the status of the guest
    }
    
    @MainActor func refreshGuests() {
        EventLists.loadUsers(eventUid: self.eventUid) { users in
            self.guests = users
            self.sectionDictionary = self.getSectionedDictionary()
            print("DEBUG: Refreshed guestlist!")
        }
    }
}
