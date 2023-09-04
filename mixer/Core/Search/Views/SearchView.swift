//
//  SearchView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var viewModel: SearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
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
                                TextField("Party, event, or meet-up? Search away...", text: $viewModel.searchText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 32)
                                    .background(Color(.systemGray4))
                                    .padding(.horizontal)
                                
                                Divider()
                                    .padding(.vertical)
                            }
                            
                            if !viewModel.searchText.isEmpty {
                                MixerMapItemSearchResultsView(viewModel: viewModel, context: $context)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 80)
                    
                    case .back, .close:
                        eventDetailView()
                        
                        userProfileView()
                        
                        hostDetailView()
                }
            }
            .disabled(homeViewModel.showSideMenu)
            .swipeGesture(direction: .right) {
                homeViewModel.actionForState()
            }
        }
    }
}

fileprivate struct MixerMapItemSearchResultsView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var context: [NavigationContext]
    
    var body: some View {
        LazyVStack(pinnedViews: [.sectionHeaders]) {
            Section {
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    let selectedResults = viewModel.results[viewModel.selectedSearchType.description] ?? []
                    
                    if selectedResults.isEmpty {
                        Text("No results found for \"\(viewModel.searchText)\"")
                            .foregroundColor(.secondary)
                            .padding(.top)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(selectedResults, id: \.self) { result in
                                SearchResultsCell(imageUrl: result.imageUrl,
                                                  title: result.title,
                                                  subtitle: result.subtitle,
                                                  type: viewModel.selectedSearchType)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        viewModel.fetchDetails(for: result,
                                                               completion: homeViewModel.navigate)
                                    }
                                }
                            }
                        }
                    }
                }
            } header: {
                StickyHeaderView(items: SearchType.allCases,
                                 selectedItem: $viewModel.selectedSearchType)
            }
        }
    }
}

extension SearchView {
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
    
    @ViewBuilder
    func userProfileView() -> some View {
        if let user = context.last?.selectedUser {
            ProfileView(user: user,
                        action: homeViewModel.navigate)
        }
    }
}
