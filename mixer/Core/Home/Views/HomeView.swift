//
//  HomeView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @State private var mapState     = MapViewState.noInput
    @State private var showSideMenu = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace var namespace
    
    var body: some View {
        Group {
            ZStack {
                if authViewModel.userSession == nil {
                    AuthFlow()
                } else if let _ = authViewModel.currentUser {
                    NavigationStack {
                        ZStack {
                            if showSideMenu {
                                SideMenuView(user: $authViewModel.currentUser)
                            }
                            
                            mapView
                                .offset(x: showSideMenu ? DeviceTypes.ScreenSize.width * 0.8 : 0)
                                .shadow(color: showSideMenu ? .black : .clear, radius: 10)
                                .onTapGesture {
                                    if showSideMenu {
                                        withAnimation(.spring()) {
                                            showSideMenu = false
                                        }
                                    }
                                }
                        }
                    }
                    .onAppear { showSideMenu = false }
                }
                
                LaunchScreenView()
                    .autoDismissView(duration: 2.5)
            }
        }
    }
}

extension HomeView {
    var mapView: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                MixerMapViewRepresentable(mapState: $mapState)
                    .ignoresSafeArea()
                
                if mapState == .noInput {
                    LocationSearchActivationView()
                        .padding(.top, 72)
                        .onTapGesture {
                            if !showSideMenu {
                                withAnimation(.spring()) {
                                    mapState = .discovering
                                }
                            }
                        }
                } else if mapState == .discovering {
                    LocationSearchView()
                } else if mapState == .eventDetail, let event = homeViewModel.selectedEvent {
                    EventDetailView(namespace: namespace)
                        .environmentObject(EventViewModel(event: event))
                } else if mapState == .hostDetail, let host = homeViewModel.selectedHost {
                    HostDetailView(namespace: namespace)
                        .environmentObject(HostViewModel(host: host))
                }
                
                MapViewActionButton(mapState: $mapState, showSideMenu: $showSideMenu)
                    .padding(.leading)
                    .padding(.top, 4)
            }
            
            if let user = authViewModel.currentUser {
                homeViewModel.viewForState(mapState, user: user)
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(LocationManager.shared.$userLocation) { location in
            if let location = location {
                homeViewModel.userLocation = location
            }
        }
        .onReceive(homeViewModel.$selectedHost) { output in
            if let _ = output, homeViewModel.selectedMixerLocation == nil {
                    self.mapState = .hostDetail
            }
        }
        .onReceive(homeViewModel.$selectedEvent) { output in
            if let _ = output, homeViewModel.selectedMixerLocation == nil {
                self.mapState = .eventDetail
            }
        }
        .onReceive(homeViewModel.$selectedMixerLocation) { location in
            if location != nil {
                switch location!.state {
                case .event:
                    self.mapState = .routeEventPreview
                case .host:
                    self.mapState = .routeHostPreview
                }
                print("DEBUG: Map state is \(self.mapState)")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct AutoDismissView: ViewModifier {
    let duration: TimeInterval
    @State private var show = true
    
    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        self.show = false
                    }
                }
            }
    }
}

extension View {
    func autoDismissView(duration: TimeInterval) -> some View {
        self.modifier(AutoDismissView(duration: duration))
    }
}
