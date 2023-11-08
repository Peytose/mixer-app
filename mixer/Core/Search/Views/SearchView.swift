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
            NavigationView {
                ZStack {
                    switch state {
                    case .menu:
                        VStack(spacing: -20) {
                            StickyHeaderView(items: SearchType.allCases,
                                             selectedItem: $viewModel.selectedSearchType)
                            
                        List {
                            if !viewModel.searchText.isEmpty {
                                NewSearchResultsView(viewModel: viewModel, context: $context)
                                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                    .listRowBackground(Color.theme.secondaryBackgroundColor)

                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.theme.backgroundColor)
                        .navigationTitle("Search")
                        .searchable(text: $viewModel.searchText,
                                    placement: .automatic,
                                    prompt: "Search Mixer")
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

fileprivate struct NewSearchResultsView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var context: [NavigationContext]
    
    var body: some View {
        
        let selectedResults = viewModel.results[viewModel.selectedSearchType.description] ?? []
        
        if selectedResults.isEmpty {
            Text("No results found for \"\(viewModel.searchText)\"")
                .foregroundColor(.secondary)
                .padding(.top)
        } else {
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


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(context: .constant([NavigationContext(state: .menu)]))
            .environmentObject(SearchViewModel())
            .environmentObject(HomeViewModel())
    }
}
