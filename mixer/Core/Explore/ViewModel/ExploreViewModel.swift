//
//  ExploreViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import Combine

enum EventSection: Int, CustomStringConvertible, CaseIterable {
    case current
    case upcoming
    
    var description: String {
        switch self {
        case .current: return "Current Events"
        case .upcoming: return "Upcoming Events"
        }
    }
}

final class ExploreViewModel: ObservableObject {
    @Published var selectedEventSection = EventSection.current {
        didSet {
            updateEvents(events)
        }
    }
    @Published var eventsForSection: [Event] = []
    @Published var hosts: [Host]             = []
    
    private var events: [Event] = []
    private let eventManager = EventManager.shared
    private let hostManager  = HostManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchEventsAndHosts()
    }
    
    
    func fetchEventsAndHosts() {
        fetchEvents()
        fetchHosts()
    }
    
    
    private func fetchEvents() {
        eventManager.$events
            .sink { [weak self] newEvents in
                self?.events = Array(newEvents)
                self?.updateEvents(Array(newEvents))
            }
            .store(in: &cancellables)
    }
    
    
    private func fetchHosts() {
        hostManager.$hosts
            .sink { [weak self] newHosts in
                self?.hosts = newHosts
            }
            .store(in: &cancellables)
    }
    
    
    private func updateEvents(_ events: [Event]) {
        if selectedEventSection == .current {
            eventsForSection = events.filter({ $0.isEventCurrentlyHappening() })
        } else if selectedEventSection == .upcoming {
            eventsForSection = events.filter({ $0.startDate > Timestamp() })
        }
        
        eventsForSection = eventsForSection.sortedByStartDate(true)
    }
}
