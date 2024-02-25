//
//  HomeView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import SwiftUI
import MapKit
import TabBar
import Kingfisher

struct HomeView: View {
    
    @State private var mapState: MapViewState = .noInput
    @StateObject var userService = UserService.shared
    
    @StateObject var mapViewModel           = MapViewModel()
    @StateObject var searchViewModel        = SearchViewModel()
    @StateObject var exploreViewModel       = ExploreViewModel()
    @StateObject var settingsViewModel      = SettingsViewModel()
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @Namespace var namespace
    
    let gradient = LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(1), Color.black.opacity(1), Color.black.opacity(0.975), Color.black.opacity(0.85), Color.black.opacity(0.3), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .top)
    
    var body: some View {
        Group {
            ZStack {
                if userService.user == nil {
                    AuthFlow()
                } else {
                    NavigationStack {
                        ZStack {
                            if let state = homeViewModel.selectedNavigationStack.last?.state {
                                switch state {
                                case .empty:
                                    ZStack {
                                        switch homeViewModel.currentTab {
                                        case .map:
                                            MapView(viewModel: mapViewModel,
                                                    mapState: $mapState)
                                        case .explore:
                                            ExploreView(viewModel: exploreViewModel,
                                                        searchViewModel: searchViewModel)
                                            .environmentObject(homeViewModel)
                                            .searchable(text: $searchViewModel.searchText,
                                                        placement: .automatic,
                                                        prompt: "Search Mixer")
                                        case .dashboard:
                                            if let _ = homeViewModel.currentHost {
                                                HostDashboardView()
                                            }
                                        case .profile:
                                            if let user = settingsViewModel.user {
                                                ProfileView(user: user)
                                                    .environmentObject(settingsViewModel)
                                                    .environmentObject(homeViewModel)
                                            }
                                        }
                                    }
                                    
                                case .back, .close:
                                    hostDetailView()
                                    
                                    eventDetailView()
                                    
                                    userDetailView()
                                }
                            }
                            
                            VStack {
                                Spacer()
                                
                                VStack {
                                    if let imageUrl = settingsViewModel.user?.profileImageUrl {
                                        TabBarItems(tabSelection: $homeViewModel.currentTab,
                                                    profileImageUrl: imageUrl)
                                    }
                                    
                                    CircleView(tabSelection: $homeViewModel.currentTab)
                                }
                                .frame(height: 40)
                                .background(Color.theme.backgroundColor.opacity(0.01))
                                .background {
                                    Rectangle()
                                        .fill(Color.theme.backgroundColor)
                                        .mask(gradient)
                                        .frame(height: homeViewModel.currentTab == .explore ? 220 : 370)
                                        .allowsHitTesting(false)
                                }
                            }
                            
                            if homeViewModel.currentState != .empty {
                                HomeViewActionButton()
                            }
                        }
                    }
                }
                
                LaunchScreenView()
                    .autoDismissView(duration: 2.5)
            }
        }
    }
}

extension HomeView {
    @ViewBuilder
    func eventDetailView() -> some View {
        if let event = homeViewModel.selectedNavigationStack.last?.selectedEvent {
            EventDetailView(event: event,
                            action: homeViewModel.navigate,
                            namespace: namespace)
        }
    }
    
    @ViewBuilder
    func hostDetailView() -> some View {
        if let host = homeViewModel.selectedNavigationStack.last?.selectedHost {
            HostDetailView(host: host,
                           action: homeViewModel.navigate,
                           namespace: namespace)
        }
    }
    
    @ViewBuilder
    func userDetailView() -> some View {
        if let user = homeViewModel.selectedNavigationStack.last?.selectedUser {
            ProfileView(user: user, action: homeViewModel.navigate)
        }
    }
}

struct CircleView: View {
    @Binding var tabSelection: TabItem
    private let availableTabs = TabItem.availableTabs()
    
    var body: some View {
        Capsule()
            .foregroundColor(tabSelection == .profile ? Color.clear : Color.theme.mixerIndigo)
            .frame(width: 60, height: 3)
            .offset(x: getOffset(), y: 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0))
    }
    
    private func getOffset() -> CGFloat {
        let width = DeviceTypes.ScreenSize.width
        let totalTabs = CGFloat(availableTabs.count)
        let tabWidth = width / totalTabs
        let selectedIndex = CGFloat(availableTabs.firstIndex(of: tabSelection) ?? 0)
        return (tabWidth * selectedIndex) - (width / 2) + (tabWidth / 2)
    }
}

struct TabBarItems: View {
    @Binding var tabSelection: TabItem
    let profileImageUrl: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.availableTabs(), id: \.self) { item in
                Spacer()
            
                Image(systemName: (tabSelection == item && tabSelection != TabItem.profile) ? item.icon + (tabSelection == TabItem.explore ? "" : ".fill") : item.icon)
                        .foregroundColor(tabSelection == item ? .white : .secondary)
                        .overlay(alignment: .center) {
                            if item == TabItem.profile {
                                KFImage(URL(string: profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 35, height: 35)
                                    .clipShape(Circle())
                                    .padding(5)
                                    .background {
                                        Circle()
                                            .strokeBorder(style: StrokeStyle(lineWidth: 3))
                                            .foregroundColor(tabSelection == item ? Color.theme.mixerIndigo : Color.clear)
                                    }
                            }
                        }
                        .frame(width: 35, height: 35)
                        .scaleEffect((tabSelection == item && item != TabItem.profile) ? 1.2 : 1)
                        .animation(Animation.timingCurve(0.2, 0.2, 0.2, 1, duration: 0.2))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.tabSelection = item
                        }
                
                Spacer()
            }
        }
        .frame(width: DeviceTypes.ScreenSize.width)
    }
}
