//
//  SearchView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var viewModel: SearchViewModel
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
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
                    MixerMapItemSearchResultsView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .padding(.top, 80)
        }
    }
}

fileprivate struct MixerMapItemSearchResultsView: View {
    @StateObject var viewModel: SearchViewModel
    
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
                                        viewModel.selectResult(result)
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
