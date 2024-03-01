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
    case today
    case upcoming
    
    var description: String {
        switch self {
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        }
    }
}

final class ExploreViewModel: ObservableObject {
    @Published var selectedEventSection = EventSection.today {
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
        fetchEvents()
        fetchHosts()
    }
    
    
    func fetchEventsAndHosts() {
        EventManager.shared.fetchExploreEvents()
        HostManager.shared.fetchHosts()
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
        if selectedEventSection == .today {
            eventsForSection = events.filter({ $0.isToday })
        } else if selectedEventSection == .upcoming {
            eventsForSection = events.filter({ $0.isFuture && !$0.isToday })
        }
        
        eventsForSection = eventsForSection.sortedByStartDate(true)
    }
}
