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
    @Environment(\.isSearching) private var isSearching: Bool
    
    @ObservedObject var viewModel: ExploreViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
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
                                    ForEach(viewModel.hosts.sorted(by: { $0.name < $1.name })) { host in
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
                                EventListView(events: viewModel.eventsForSection,
                                              namespace: namespace) { event, namespace in
                                    EventCellView(event: event, namespace: namespace)
                                        .onTapGesture {
                                            homeViewModel.navigate(to: .close,
                                                                   withEvent: event)
                                        }
                                }
                            } header: {
                                StickyHeaderView(items: EventSection.allCases,
                                                 selectedItem: $viewModel.selectedEventSection)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
                .refreshable {
                    viewModel.fetchEventsAndHosts()
                }
                
                if isSearching {
                    SearchView(viewModel: searchViewModel)
                        .environmentObject(homeViewModel)
                }
            }
            .overlay(alignment: .top) {
                Image("Blob 1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300, alignment: .top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .opacity(0.8)
                    .offset(x: -40, y: -355)
            }
        }
        .swipeGesture(direction: .right) {
            homeViewModel.actionForState()
        }
    }
}
