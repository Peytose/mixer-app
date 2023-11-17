//
//  HostDashboardViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 11/13/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

final class HostDashboardViewModel: ObservableObject {
    @Published var host: Host
    @Published var memberCount: Int = 0
    @Published var eventCount: Int = 0
    @Published var recentEvent: Event?
    @Published var guests: [EventGuest]?
    
    @Published var totalNumGuests: Int?
    @Published var mostInvitesUser: String?
    @Published var mostInvitesCount: Int?
    @Published var mostCheckInsUser: String?
    @Published var mostCheckInsCount: Int?
    @Published var firstGuestName: String?
    @Published var firstGuestTime: Timestamp?
    
    init(host: Host) {
        self.host = host
        
        getNumberOfMembers()
        getNumberOfEvents()
        fetchMostRecentEvent()
    }
    
    
    func calculateStatistics() {
        guard let guests = self.guests else {
            print("DEBUG: No guests found")
            return
        }
        
        // Total Guests
        self.totalNumGuests = guests.count
        print("DEBUG: Total number of guests - \(self.totalNumGuests ?? 0)")

        // Most Invites
        let invitesCount = Dictionary(grouping: guests, by: { $0.invitedBy })
            .mapValues { $0.count }
        if let mostInvites = invitesCount.max(by: { $0.value < $1.value }) {
            self.mostInvitesUser = mostInvites.key
            self.mostInvitesCount = mostInvites.value
            print("DEBUG: Most invites by \(mostInvites.key) with count \(mostInvites.value)")
        } else {
            print("DEBUG: No data found for most invites")
        }

        // Most Check-ins
        let validCheckIns = guests.filter { $0.checkedInBy != nil }
        let checkInsCount = Dictionary(grouping: validCheckIns, by: { $0.checkedInBy! })
            .mapValues { $0.count }

        if let mostCheckIns = checkInsCount.max(by: { $0.value < $1.value }) {
            self.mostCheckInsUser = mostCheckIns.key
            self.mostCheckInsCount = mostCheckIns.value
            print("DEBUG: Most check-ins by \(mostCheckIns.key) with count \(mostCheckIns.value)")
        } else {
            print("DEBUG: No data found for most check-ins")
        }

        // First Guest
        if let firstGuest = validCheckIns.min(by: { $0.timestamp ?? Timestamp() < $1.timestamp ?? Timestamp() }) {
            self.firstGuestName = firstGuest.name
            self.firstGuestTime = firstGuest.timestamp
            print("DEBUG: First guest is \(firstGuest.name) at \(firstGuest.timestamp?.dateValue())")
        } else {
            print("DEBUG: No data found for first guest")
        }
    }

    
    
    func fetchMostRecentEvent() {
        guard let hostId = host.id else { return }
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .whereField("endDate", isLessThan: Timestamp())
            .order(by: "endDate", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting most recent event. \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot?.documents.first else { return }
                let event = try? snapshot.data(as: Event.self)
                
                DispatchQueue.main.async {
                    self.recentEvent = event
                }
                
                guard let eventId = event?.id else { return }
                
                COLLECTION_EVENTS
                    .document(eventId)
                    .collection("guestlist")
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("DEBUG: Error getting guestlist. \(error.localizedDescription)")
                            return
                        }
                        
                        guard let documents = snapshot?.documents else { return }
                        let guests = documents.compactMap({ try? $0.data(as: EventGuest.self )})
                        
                        DispatchQueue.main.async {
                            self.guests = guests
                            self.calculateStatistics()
                        }
                    }
            }
    }
    
    
    func getNumberOfEvents() {
        guard let hostId = host.id else { return }
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .count
            .getAggregation(source: .server) { snapshot, _ in
                guard let count = snapshot?.count.intValue else { return }
                
                DispatchQueue.main.async {
                    self.eventCount = count
                }
            }
    }
    
    
    func getNumberOfMembers() {
        guard let hostId = host.id else { return }
        
        COLLECTION_HOSTS
            .document(hostId)
            .collection("member-list")
            .whereField("status", isEqualTo: 1)
            .count
            .getAggregation(source: .server) { snapshot, _ in
                guard let count = snapshot?.count.intValue else { return }
                
                DispatchQueue.main.async {
                    self.memberCount = count
                }
            }
    }
}