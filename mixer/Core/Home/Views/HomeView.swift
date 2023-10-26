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
    @StateObject var userService = UserService.shared
    @StateObject var exploreViewModel = ExploreViewModel()
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
                                SideMenuView()
                            }
                            
                            ZStack {
                                ZStack {
                                    switch homeViewModel.currentTab {
                                    case .map:
                                        MapView(mapState: $mapState)
                                            .environmentObject(MapViewModel())
                                    case .explore:
                                        ExploreView(context: $homeViewModel.selectedNavigationStack)
                                            .environmentObject(exploreViewModel)
                                        
                                    case .search:
                                        SearchView(context: $homeViewModel.selectedNavigationStack)
                                            .environmentObject(SearchViewModel())
                                    }
                                }
                                .shadow(color: homeViewModel.showSideMenu ? .black : .clear, radius: 10)
                                
                                VStack {
                                    Spacer()
                                    
                                    VStack {
                                        TabBarItems(tabSelection: $homeViewModel.currentTab)
                                        
                                        CircleView(tabSelection: $homeViewModel.currentTab)
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
                                .onChange(of: homeViewModel.showSideMenu) { _ in
                                    hideKeyboard()
                                }
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
        Capsule()
            .foregroundColor(Color.theme.mixerIndigo)
            .frame(width: 60, height: 3)
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
