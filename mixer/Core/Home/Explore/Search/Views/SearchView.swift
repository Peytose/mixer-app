//
//  SearchView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace var namespace
    
    var body: some View {
        VStack(spacing: -20) {
            StickyHeaderView(items: SearchType.allCases,
                             selectedItem: $viewModel.selectedSearchType)
            
            List {
                if !viewModel.searchText.isEmpty {
                    MixerMapItemSearchResultsView(viewModel: viewModel)
                        .environmentObject(homeViewModel)
                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        .listRowBackground(Color.theme.secondaryBackgroundColor)
                    
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.theme.backgroundColor)
    }
}

fileprivate struct MixerMapItemSearchResultsView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        let selectedResults = viewModel.results[viewModel.selectedSearchType.description] ?? []
        
        if selectedResults.isEmpty {
            Text("No results found for \"\(viewModel.searchText)\"")
                .foregroundColor(.secondary)
                .padding(.top)
        } else {
            ForEach(selectedResults, id: \.self) { result in
                ItemInfoCell(
                    title: result.title,
                    subtitle: "\(viewModel.selectedSearchType == .users || viewModel.selectedSearchType == .hosts ? "@" : "")\(result.subtitle)",
                    imageUrl: result.imageUrl
                )
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: SearchViewModel())
    }
}
