//
//  HomeView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import SwiftUI
import MapKit
import TabBar

struct HomeView: View {
    @State private var mapState: MapViewState = .noInput
    @ObservedObject var userService = UserService.shared
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var hostManager: HostManager
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
                            if homeViewModel.showSideMenu {
                                SideMenuView(user: $userService.user)
                            }
                            
                            ZStack {
                                ZStack {
                                    switch homeViewModel.currentTab {
                                    case .map:
                                        MapView(mapState: $mapState)
                                            .environmentObject(MapViewModel())
                                    case .explore:
                                        ExploreView()
                                            .environmentObject(ExploreViewModel())
                                    case .search:
                                        SearchView()
                                            .environmentObject(SearchViewModel())
                                    }
                                    
                                    eventDetailView()
                                    
                                    hostDetailView()
                                }
                                .shadow(color: homeViewModel.showSideMenu ? .black : .clear, radius: 10)
                                
                                VStack {
                                    Spacer()
                                    
                                    ZStack {
                                        CircleView(tabSelection: $homeViewModel.currentTab)
                                        
                                        TabBarItems(tabSelection: $homeViewModel.currentTab)
                                    }
                                    .opacity(homeViewModel.showSideMenu ? 0 : 1)
                                    .frame(height: 80)
                                    .background(Color.theme.backgroundColor.opacity(0.01))
                                    .background {
                                        Rectangle()
                                            .fill(Color.theme.backgroundColor)
                                            .mask(gradient)
                                            .frame(height: 370)
                                            .allowsHitTesting(false)
                                    }
                                }
                            }
                            .offset(x: homeViewModel.showSideMenu ? DeviceTypes.ScreenSize.width * 0.8 : 0)
                            .onTapGesture {
                                if homeViewModel.showSideMenu {
                                    withAnimation(.spring()) {
                                        homeViewModel.showSideMenu = false
                                    }
                                }
                            }
                            
                            HomeViewActionButton()
                        }
                    }
                    .onAppear { homeViewModel.showSideMenu = false }
                }
                
                LaunchScreenView()
                    .autoDismissView(duration: 2.5)
            }
        }
    }
}

struct CircleView: View {
    @Binding var tabSelection: TabItem
    
    var body: some View {
        Circle()
            .foregroundColor(Color.theme.mixerIndigo)
            .frame(width: 60, height: 60)
            .offset(x: getOffset(), y: 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0))
    }
    
    private func getOffset() -> CGFloat {
        let width = DeviceTypes.ScreenSize.width
        let totalTabs = CGFloat(TabItem.allCases.count)
        let tabWidth = width / totalTabs
        let selectedIndex = CGFloat(tabSelection.rawValue)
        return (tabWidth * selectedIndex) - (width / 2) + (tabWidth / 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct TabBarItems: View {
    @Binding var tabSelection: TabItem
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { item in
                Spacer()
                
                Image(systemName: (tabSelection == item && tabSelection != TabItem.search) ? item.icon + ".fill" : item.icon)
                    .foregroundColor(tabSelection == item ? .white : .secondary)
                    .frame(width: 35, height: 35)
                    .scaleEffect(tabSelection == item ? 1.3 : 1)
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

extension HomeView {
    @ViewBuilder
    func eventDetailView() -> some View {
        if let event = eventManager.selectedEvent,
           homeViewModel.currentState == .embeddedEventDetailView || homeViewModel.currentState == .eventDetailView {
            EventDetailView()
                .environmentObject(EventViewModel(event: event))
        }
    }

    @ViewBuilder
    func hostDetailView() -> some View {
        if let host = hostManager.selectedHost,
           homeViewModel.currentState == .embeddedHostDetailView || homeViewModel.currentState == .hostDetailView {
            HostDetailView(namespace: namespace)
                .environmentObject(HostViewModel(host: host))
        }
    }
}
