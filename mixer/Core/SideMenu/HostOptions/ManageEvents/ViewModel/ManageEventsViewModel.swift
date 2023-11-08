//
//  ManageEventsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 9/14/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

enum EventState: Int, CustomStringConvertible, CaseIterable {
    case ongoing
    case upcoming
    case past
    
    init(event: Event) {
        if event.endDate < Timestamp() {
            self = .past
        } else if event.startDate <= Timestamp() {
            self = .ongoing
        } else {
            self = .upcoming
        }
    }
    
    var description: String {
        switch self {
        case .ongoing, .upcoming:
            return "Active"
        case .past:
            return "Past"
        }
    }
}

class ManageEventsViewModel: ObservableObject {
    @Published var events: [Event] = [] {
        didSet {
            updateEventsForSelectedState()
        }
    }
    @Published var selectedEvent: Event?
    @Published var eventsForSelectedState: [Event] = []
    @Published var selectedHost: Host? {
        didSet {
            fetchHostEvents()
        }
    }

    @Published var currentState: EventState = .ongoing {
        didSet {
            updateEventsForSelectedState()
        }
    }
    
    private var eventManager = EventManager.shared
    
    init() {
        self.selectedHost = UserService.shared.user?.currentHost
    }
    
    
    private func updateEventsForSelectedState() {
        self.eventsForSelectedState = events.filter { EventState(event: $0).description == currentState.description }
    }

    
    private func fetchHostEvents() {
        guard let host = selectedHost else { return }
        eventManager.fetchEvents(for: host) { events in
            // Filter out unconfirmed events
            let confirmedEvents = events.filter { event in
                !(event.pendingPlannerIds?.isEmpty ?? false)
            }
            self.events = confirmedEvents
        }
    }
}

// IDEA: Put a cap on the # of times a user can edit their event, but a future
//       membership plan allows for unlimited changes, or perhaps just more.
