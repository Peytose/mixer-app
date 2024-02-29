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
    @Published var currentTab: TabItem = .explore {
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
        return selectedNavigationStack.last?.state ?? .empty
    }
    @Published var currentHost: Host?
    
    private let service = UserService.shared
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        for tab in TabItem.availableTabs() {
            navigationStackTabMap[tab] = [NavigationContext(state: .empty)]
        }
        
        service.$user
            .sink { user in
                self.currentHost = user?.currentHost
                
                if self.currentHost != nil && self.navigationStackTabMap[TabItem.dashboard] == nil {
                    self.navigationStackTabMap[TabItem.dashboard] = [NavigationContext(state: .empty)]
                }
            }
            .store(in: &cancellable)
    }
    
    
    func iconForState() -> String {
        switch currentState {
        case .empty:
            return ""
        case .back:
            return "arrow.left"
        case .close:
            return "xmark"
        }
    }
    
    
    func actionForState() {
        switch currentState {
        case .empty:
            break
        case .back, .close:
            withAnimation(.easeInOut) {
                navigateBack()
            }
        }
    }
}

// MARK: - Helper functions
extension HomeViewModel {
    func pushContext(_ context: NavigationContext) {
        navigationStackTabMap[currentTab]?.append(context)
        selectedNavigationStack = navigationStackTabMap[currentTab] ?? [NavigationContext(state: .empty)]
    }
    
    
    func popContext() -> NavigationContext {
        // Pop the last context if there's more than one
        if navigationStackTabMap[currentTab]?.count ?? 0 > 1 {
            return navigationStackTabMap[currentTab]?.popLast() ?? NavigationContext(state: .empty)
        }
        
        // If there's only one context, return it without popping
        return navigationStackTabMap[currentTab]?.last ?? NavigationContext(state: .empty)
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
