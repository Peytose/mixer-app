//
//  HomeViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine
import MapKit

class HomeViewModel: ObservableObject {
    @Published var navigationStack: [NavigationContext] = []
    @Published var currentTab: TabItem = .map
    @Published var currentState: NavigationState?
    @Published var showSideMenu: Bool = false
    @Published var selectedEvent: Event? = nil
    @Published var selectedHost: Host? = nil
    

    func iconForState() -> String {
        if let state = self.currentState {
            switch state {
            case .embeddedEventDetailView, .embeddedHostDetailView:
                return "arrow.left"
            case .eventDetailView, .hostDetailView:
                return "xmark"
            default: return ""
            }
        } else {
            return "line.3.horizontal"
        }
    }
    
    
    func actionForState() {
        if let state = self.currentState {
            switch state {
            case .embeddedEventDetailView, .embeddedHostDetailView:
                navigateBack()
            case .eventDetailView, .hostDetailView:
                currentState = nil
            default: break
            }
        } else {
            showSideMenu.toggle()
        }
    }
}

// MARK: - Helper functions
extension HomeViewModel {
    func handleTap(to state: NavigationState, event: Event? = nil, host: Host? = nil, eventManager: EventManager? = nil, hostManager: HostManager? = nil) {
        if let selectedEvent = event {
            // Update the selected event in the EventManager and navigate accordingly
            eventManager?.selectedEvent = selectedEvent
            navigate(to: state, withEvent: selectedEvent)
        } else if let selectedHost = host {
            // Update the selected host in the HostManager and navigate accordingly
            hostManager?.selectedHost = selectedHost
            navigate(to: state, withHost: selectedHost)
        }
    }

    
    func navigate(to state: NavigationState, withEvent event: Event? = nil, withHost host: Host? = nil) {
        let currentContext = NavigationContext(state: currentState, selectedEvent: event, selectedHost: host)
        navigationStack.append(currentContext)
        currentState = state
        selectedEvent = event
        selectedHost = host
    }

    
    private func navigateBack() {
        if let previousContext = navigationStack.popLast() {
            currentState = previousContext.state
            selectedEvent = previousContext.selectedEvent
            selectedHost = previousContext.selectedHost
        }
    }
}
