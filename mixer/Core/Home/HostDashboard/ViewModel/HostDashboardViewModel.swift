//
//  HostDashboardViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 11/13/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine

final class HostDashboardViewModel: ObservableObject {
    @Published var currentHost: Host?
    @Published var memberHosts: [Host]?
    @Published var memberCount: Int = 0
    @Published var eventCount: Int = 0
    @Published var recentEvent: Event?
    @Published var guests: [EventGuest]?
    
    @Published var recentStatistics: [String: String] = [:]
    @Published var quickStatistics: [String: (String, String, String)] = [:] {
        didSet {
//            self.hideLoadingView()
        }
    }
    
    //Component-specific loading states
    @Published var isLoadingEventCount: Bool = false
    @Published var isLoadingMemberCount: Bool = false
    @Published var isLoadingRecentEvents: Bool = false
    @Published var isLoadingRecentEventStatistics: Bool = false
    @Published var isLoadingQuickFacts: Bool = false

    private let service = UserService.shared
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        service.$user
            .sink { user in
                self.currentHost = user?.currentHost
                self.memberHosts = user?.associatedHosts
                
                self.getNumberOfMembers()
                self.getNumberOfEvents()
                self.fetchMostRecentEvent()
            }
            .store(in: &cancellable)
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
        
        self.isLoadingRecentEventStatistics = true
        
        var recentStats = [String: String]()
        
        // Total Guests
        recentStats["Total Guests:"] = "\(guests.count)"
        print("DEBUG: Total number of guests - \(guests.count)")

        // Most Invites
        let invitesCount = Dictionary(grouping: guests, by: { $0.invitedBy })
            .mapValues { $0.count }
        if let mostInvites = invitesCount.max(by: { $0.value < $1.value }) {
            let invitee = mostInvites.key ?? "Unknown" // Provide a default value if nil
            recentStats["Most Invites:"] = "\(invitee.firstSubstringBeforeSpace()) (\(mostInvites.value))"
            print("DEBUG: Most invites by \(invitee) with count \(mostInvites.value)")
        }

        // Most Check-ins
        let validCheckIns = guests.filter { $0.checkedInBy != nil }
        let checkInsCount = Dictionary(grouping: validCheckIns, by: { $0.checkedInBy! })
            .mapValues { $0.count }
        if let mostCheckIns = checkInsCount.max(by: { $0.value < $1.value }) {
            recentStats["Most Check-ins:"] = "\(mostCheckIns.key.firstSubstringBeforeSpace()) (\(mostCheckIns.value))"
            print("DEBUG: Most check-ins by \(mostCheckIns.key) with count \(mostCheckIns.value)")
        }

        // First Guest
        if let firstGuest = validCheckIns.min(by: { $0.timestamp?.dateValue() ?? Date() < $1.timestamp?.dateValue() ?? Date() }) {
            let guestName = firstGuest.name.capitalized
            if let firstGuestTime = firstGuest.timestamp?.getTimestampString(format: "h:mm aa") {
                recentStats["First Guest:"] = "\(guestName.firstSubstringBeforeSpace()) (\(firstGuestTime))"
                print("DEBUG: First guest is \(guestName) at \(firstGuestTime)")
            }
        }
        
        self.recentStatistics = recentStats
        self.isLoadingRecentEventStatistics = false
        
        
        self.isLoadingQuickFacts = true
        var quickStats = [String: (String, String, String)]()
        
        // Most Frequent University
        let universityCounts = Dictionary(grouping: guests, by: { $0.university })
            .mapValues { $0.count }
        if let mostFrequentUniversity = universityCounts.max(by: { $0.value < $1.value }) {
            // Assuming you have a way to get the university name from its ID
            let universityName = mostFrequentUniversity.key?.shortName ?? mostFrequentUniversity.key?.name ?? "N/A"
            quickStats["Most Frequent University"] = (universityName, "\(mostFrequentUniversity.value)", "from this school")
            print("DEBUG: Most frequent university is \(universityName) with \(mostFrequentUniversity.value) guests")
        }
        
        // Calculate Average Age and Age Range
        let ages = guests.compactMap { $0.age } // Filter out nil ages
        if !ages.isEmpty {
            let sumOfAges = ages.reduce(0, +)
            let averageAge = Double(sumOfAges) / Double(ages.count)
            print("DEBUG: Average: \(averageAge). Sum: \(sumOfAges). Count: \(ages.count).")
            let ageRange = "\(ages.min()!)-\(ages.max()!)"

            // Formatting the average age to one decimal place
            let formattedAverageAge = String(format: "%.1f", averageAge)

            quickStats["Average Age"] = (formattedAverageAge, ageRange, "age range")
            print("DEBUG: Average Age is \(formattedAverageAge) with an age range of \(ageRange)")
        }
        
        // Most Represented Field of Study
        let majors = guests.compactMap({ $0.major }) // Filter out nil majors
        if !majors.isEmpty {
            let majorCount = Dictionary(grouping: majors, by: { $0 })
                .mapValues { $0.count }
            if let mostRepresentedMajor = majorCount.max(by: { $0.value < $1.value }) {
                quickStats["Most Represented Major"] = (mostRepresentedMajor.key.description, "\(mostRepresentedMajor.value)", "students attending")
                print("DEBUG: Most represented major is \(mostRepresentedMajor.key) with \(mostRepresentedMajor.value) guests")
            }
        }

        self.quickStatistics = quickStats
        self.isLoadingQuickFacts = false
    }
    
    
    func fetchMostRecentEvent() {
        guard let hostId = currentHost?.id else { return }
        self.isLoadingRecentEvents = true
        
        if let mostRecentEvent = Array(EventManager.shared.events).mostRecentEvent {
            DispatchQueue.main.async {
                self.recentEvent = mostRecentEvent
                self.isLoadingRecentEvents = false
            }
            fetchGuestListForEvent(eventId: mostRecentEvent.id ?? "")
        } else {
            EventManager.shared.fetchMostRecentEvent(for: hostId) { event in
                DispatchQueue.main.async {
                    if let event = event.first {
                        self.recentEvent = event
                        self.fetchGuestListForEvent(eventId: event.id ?? "")
                        self.isLoadingRecentEvents = false
                    } else {
                        print("DEBUG: No event was returned. Potentially an error, or the host may not have past events.")
                    }
                }
            }
        }
    }
    
    
    func getNumberOfEvents() {
        guard let hostId = currentHost?.id else { return }
        
        self.isLoadingEventCount = true
        
        COLLECTION_EVENTS
            .whereField("hostIds", arrayContains: hostId)
            .count
            .getAggregation(source: .server) { snapshot, _ in
                guard let count = snapshot?.count.intValue else { return }
                
                DispatchQueue.main.async {
                    self.eventCount = count
                    self.isLoadingEventCount = false
                }
            }
    }
    
    
    func getNumberOfMembers() {
        guard let hostId = currentHost?.id else { return }
        
        self.isLoadingMemberCount = true
        
        COLLECTION_HOSTS
            .document(hostId)
            .collection("member-list")
            .whereField("status", isEqualTo: 1)
            .count
            .getAggregation(source: .server) { snapshot, _ in
                guard let count = snapshot?.count.intValue else { return }
                
                DispatchQueue.main.async {
                    self.memberCount = count
                    self.isLoadingMemberCount = false

                }
            }
    }
}

extension HostDashboardViewModel {
    func fetchGuestListForEvent(eventId: String) {
        let queryKey = QueryKey(collectionPath: "events/\(eventId)/guestlist")

        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 86400) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting guestlist. \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                let guests = documents.compactMap({ try? $0.data(as: EventGuest.self) })
                self.processGuests(guests)
            }
    }

    
    func processGuests(_ guests: [EventGuest]) {
        let uniqueUniversityIds = Set(guests.map { $0.universityId })

        UserService.shared.fetchUniversities(with: Array(uniqueUniversityIds)) { universities in
            let updatedGuests = guests.map { guest -> EventGuest in
                var guest = guest
                if let university = universities.first(where: { $0.id == guest.universityId }) {
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

    
    func selectHost(_ host: Host) {
        self.recentEvent = nil
        service.selectHost(host)
    }
}
