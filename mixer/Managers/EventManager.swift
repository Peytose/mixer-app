//
//  EventManager.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class EventManager: ObservableObject {
    static let shared = EventManager()
    @Published var selectedEvent: Event?
    @Published var events         = [Event]()
    @Published var hostPastEvents = [Event]()
    @Published var userPastEvents = [Event]()
    
    init() {
        self.fetchAvailableEvents()
    }
    
    
    func fetchAvailableEvents() {
        COLLECTION_EVENTS
            .whereField("isPrivate", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting events: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                self.events = events
            }
    }
    
    
    func getGuestlistAndRequestStatus(for event: Event,
                                  completion: @escaping (Bool, Bool) -> Void) {
        guard let uid = UserService.shared.user?.id else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let data = snapshot?.data() else {
                    completion(false, false)
                    return
                }
                
                let guestStatus = GuestStatus(rawValue: data["status"] as? Int ?? -1)
                
                let didGuestlist = guestStatus != .requested
                let didRequest = guestStatus == .requested
                
                completion(didGuestlist, didRequest)
            }
    }
    
    
    func fetchEvents(for host: Host, completion: @escaping ([Event]) -> Void) {
        guard UserService.shared.user?.associatedHosts?.contains(where: { $0 == host }) ?? false else { return }
        guard let hostId = host.id else { return }
        
        COLLECTION_EVENTS
            .whereField("hostId", isEqualTo: hostId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting events for \(host.name). \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                completion(events)
            }
    }

    
    func fetchHostPastEvents(for hostId: String) {
        COLLECTION_EVENTS
            .whereField("hostId", isEqualTo: hostId)
            .whereField("endDate", isLessThan: Timestamp())
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting host past events: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let events = documents.compactMap({ try? $0.data(as: Event.self) })
                self.hostPastEvents = events
            }
    }

    
    func fetchUserPastEvents(for userId: String) {
        COLLECTION_USERS
            .document(userId)
            .collection("events-attended")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.compactMap({ $0.documentID })
                let dispatchGroup = DispatchGroup()
                var attendedEvents: [Event] = []
                
                for eventId in eventIds {
                    dispatchGroup.enter()
                    
                    COLLECTION_EVENTS
                        .document(eventId)
                        .getDocument { snapshot, error in
                            if let error = error {
                                print("DEBUG: Error getting host past events: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let snapshot = snapshot else { return }
                            guard let event = try? snapshot.data(as: Event.self) else { return }
                            attendedEvents.append(event)
                            
                            dispatchGroup.leave()
                        }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.userPastEvents = attendedEvents
                }
                
            }
    }
}

