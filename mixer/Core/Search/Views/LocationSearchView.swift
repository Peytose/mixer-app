//
//  LocationSearchView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/1/23.
//

import SwiftUI

struct LocationSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                TextField("Party, event, or meet-up? Search away...", text: $viewModel.searchText)
                    .frame(height: 32)
                    .background(Color(.systemGray4))
                    .padding(.horizontal)
                    .padding(.top, 80)
                
                Divider()
                    .padding(.vertical)
                
                if viewModel.results.isEmpty {
                    ExploreView()
                } else {
                    LocationSearchResultsView(viewModel: viewModel)
                }
            }
        }
    }
}

struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView()
    }
}

struct LocationSearchResultsView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(Array(viewModel.results), id: \.self) { result in
                    LocationSearchResultsCell(location: result)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.selectLocation(result)
                        }
                    }
                }
            }
        }
    }
}

