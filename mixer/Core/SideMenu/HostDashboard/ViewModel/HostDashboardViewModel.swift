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
    
    @Published var statistics: [String: String] = [:]
    
    init(host: Host) {
        self.host = host
        
        getNumberOfMembers()
        getNumberOfEvents()
        fetchMostRecentEvent()
    }
    
    
    func generateCharts() -> [PieChartModel] {
        guard let guests = self.guests else {
            print("DEBUG: No guests found")
            return []
        }

        // University distributions
        let universityDistribution = Dictionary(grouping: guests, by: { $0.university })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        var colorIndex = 0
            let schoolDistributionSegments = universityDistribution.map { university -> PieChartSegment in
                let segment = PieChartSegment(
                    value: university.value,
                    color: Color.chartPalette[colorIndex % Color.chartPalette.count],
                    label: (university.key?.shortName ?? university.key?.name) ?? "n/a"
                )
                colorIndex += 1
                return segment
            }
        
        // Gender distribution
        let genderDistribution = Dictionary(grouping: guests, by: { $0.gender })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let genderDistributionSegments = genderDistribution.map { gender -> PieChartSegment in
            let segment = PieChartSegment(
                value: gender.value,
                color: Color.genderChartPallete[gender.key.rawValue],
                label: gender.key.description
            )
            return segment
        }

        let schoolDistributionChart = PieChartModel(title: "School Distribution", segments: schoolDistributionSegments)
        let genderDistributionChart = PieChartModel(title: "Gender Distribution", segments: genderDistributionSegments)

        return [schoolDistributionChart, genderDistributionChart]
    }
    
    
    func calculateStatistics() {
        guard let guests = self.guests else {
            print("DEBUG: No guests found")
            return
        }
        
        var stats = [String: String]()
        
        // Total Guests
        stats["Total Guests:"] = "\(guests.count)"
        print("DEBUG: Total number of guests - \(guests.count)")

        // Most Invites
        let invitesCount = Dictionary(grouping: guests, by: { $0.invitedBy })
            .mapValues { $0.count }
        if let mostInvites = invitesCount.max(by: { $0.value < $1.value }) {
            let invitee = mostInvites.key ?? "Unknown" // Provide a default value if nil
            stats["Most Invites:"] = "\(invitee) (\(mostInvites.value))"
            print("DEBUG: Most invites by \(invitee) with count \(mostInvites.value)")
        }

        // Most Check-ins
        let validCheckIns = guests.filter { $0.checkedInBy != nil }
        let checkInsCount = Dictionary(grouping: validCheckIns, by: { $0.checkedInBy! })
            .mapValues { $0.count }
        if let mostCheckIns = checkInsCount.max(by: { $0.value < $1.value }) {
            stats["Most Check-ins:"] = "\(mostCheckIns.key) (\(mostCheckIns.value))"
            print("DEBUG: Most check-ins by \(mostCheckIns.key) with count \(mostCheckIns.value)")
        }

        // First Guest
        if let firstGuest = validCheckIns.min(by: { $0.timestamp?.dateValue() ?? Date() < $1.timestamp?.dateValue() ?? Date() }) {
            let guestName = firstGuest.name.capitalized
            if let firstGuestTime = firstGuest.timestamp?.getTimestampString(format: "h:mm aa") {
                stats["First Guest:"] = "\(guestName) (\(firstGuestTime))"
                print("DEBUG: First guest is \(guestName) at \(firstGuestTime)")
            }
        }
        
        self.statistics = stats
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
                        // Fetching unique university IDs from guests
                        let uniqueUniversityIds = Set(guests.map { $0.universityId })

                        // Fetch universities and then associate them with guests
                        UserService.shared.fetchUniversities(with: Array(uniqueUniversityIds)) { universities in
                            // Associate each guest with their respective university
                            let updatedGuests = guests.map { guest -> EventGuest in
                                var guest = guest
                                let universityId = guest.universityId
                                if let university = universities.first(where: { $0.id == universityId }) {
                                    guest.university = university
                                }
                                return guest
                            }

                            DispatchQueue.main.async {
                                self.guests = updatedGuests
                                self.calculateStatistics()
                            }
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
