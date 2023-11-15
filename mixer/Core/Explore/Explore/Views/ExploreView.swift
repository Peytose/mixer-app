//
//  ExploreView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import FirebaseFirestore

struct ExploreView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var exploreViewModel: ExploreViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace var namespace
    @Binding var context: [NavigationContext]
    
    var body: some View {
        if let state = context.last?.state {
            ZStack {
                Color.theme.backgroundColor
                    .ignoresSafeArea()
                
                switch state {
                    case .menu:
                        ScrollView(showsIndicators: false) {
                            VStack {
                                // Featured Hosts Section
                                VStack(spacing: 10) {
                                    Text("Featured Hosts")
                                        .largeTitle()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                    
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(exploreViewModel.hosts.sorted(by: { $0.name < $1.name })) { host in
                                                FeaturedHostCell(host: host, namespace: namespace)
                                                    .onTapGesture {
                                                        homeViewModel.navigate(to: .close, withHost: host)
                                                    }
                                            }
                                        }
                                    }
                                }
                                
                                // Segmented Event Header
                                LazyVStack(pinnedViews: [.sectionHeaders]) {
                                    Section {
                                        EventListView(events: exploreViewModel.eventsForSection,
                                                      namespace: namespace) { event, namespace in
                                            EventCellView(event: event, namespace: namespace)
                                                .onTapGesture {
                                                    homeViewModel.navigate(to: .close,
                                                                           withEvent: event)
                                                }
                                        }
                                    } header: {
                                        StickyHeaderView(items: EventSection.allCases,
                                                         selectedItem: $exploreViewModel.selectedEventSection)
                                    }
                                }
                                .padding(.bottom, 100)
                            }
                        }
                        .padding(.top, 60)
                        .refreshable {
                            exploreViewModel.fetchEventsAndHosts()
                        }
                        
                        
                    case .back, .close:
                        hostDetailView()
                        
                        eventDetailView()
                }
            }
            .disabled(homeViewModel.showSideMenu)
            .swipeGesture(direction: .right) {
                homeViewModel.actionForState()
            }
        }
    }
}

extension ExploreView {
    @ViewBuilder
    func eventDetailView() -> some View {
        if let event = context.last?.selectedEvent {
            EventDetailView(event: event,
                            action: homeViewModel.navigate)
        }
    }

    @ViewBuilder
    func hostDetailView() -> some View {
        if let host = context.last?.selectedHost {
            HostDetailView(host: host,
                           action: homeViewModel.navigate)
        }
    }
}
