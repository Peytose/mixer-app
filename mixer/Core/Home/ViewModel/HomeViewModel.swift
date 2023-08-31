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
    @Published var path = NavigationPath()
    @Published var currentTab: TabItem = .map {
        didSet {
            selectedNavigationStack = navigationStackTabMap[currentTab] ?? []
        }
    }
    @Published var navigationStackTabMap: [TabItem: [NavigationContext]] = [:] {
        didSet {
            selectedNavigationStack = navigationStackTabMap[currentTab] ?? []
        }
    }
    @Published var selectedNavigationStack: [NavigationContext] = []
    var currentState: NavigationState {
        if let context = selectedNavigationStack.first(where: { $0.state == .close }) {
            print("DEBUG: Context user \(context.selectedUser)")
        }
        
        return selectedNavigationStack.last?.state ?? .menu
    }
    @Published var showSideMenu: Bool = false
    
    init() {
        for tab in TabItem.allCases {
            navigationStackTabMap[tab] = [NavigationContext(state: .menu)]
        }
    }

    func iconForState() -> String {
        switch currentState {
        case .menu:
            return showSideMenu ? "chevron.right" : "line.3.horizontal"
        case .back:
            return "arrow.left"
        case .close:
            return "xmark"
        }
    }
    
    func actionForState() {
        switch currentState {
        case .menu:
            showSideMenu.toggle()
        case .back, .close:
            navigateBack()
        }
    }
}

// MARK: - Helper functions
extension HomeViewModel {
    func pushContext(_ context: NavigationContext) {
        navigationStackTabMap[currentTab]?.append(context)
        selectedNavigationStack = navigationStackTabMap[currentTab] ?? [NavigationContext(state: .menu)]
    }
    
    
    func popContext() -> NavigationContext {
        // Pop the last context if there's more than one
        if navigationStackTabMap[currentTab]?.count ?? 0 > 1 {
            return navigationStackTabMap[currentTab]?.popLast() ?? NavigationContext(state: .menu)
        }
        
        // If there's only one context, return it without popping
        return navigationStackTabMap[currentTab]?.last ?? NavigationContext(state: .menu)
    }


    
    func navigate(to state: NavigationState,
                  withEvent event: Event? = nil,
                  withHost host: Host? = nil,
                  withUser user: User? = nil) {
        let currentContext = NavigationContext(state: state,
                                               selectedEvent: event,
                                               selectedHost: host,
                                               selectedUser: user)
        pushContext(currentContext)
    }
    
    
    private func navigateBack() {
        let _ = popContext() // Pop the current context
    }
}
