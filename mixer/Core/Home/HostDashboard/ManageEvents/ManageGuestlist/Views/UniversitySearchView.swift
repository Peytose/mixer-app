//
//  UniversitySearchView.swift
//  mixer
//
//  Created by Peyton Lyons on 10/27/23.
//

import SwiftUI

struct UniversitySearchView: View {
    @ObservedObject var viewModel: UniversitySearchViewModel
    @FocusState private var isTextFieldFocused: Bool
    let action: (University) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "text.magnifyingglass")
                    .imageScale(.small)
                    .foregroundColor(Color.secondary)
                
                TextField("Search universities..", text: $viewModel.searchText)
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { newValue in
                        viewModel.isShowingSearchResults = newValue
                    }
                
                Spacer()
            }
            
            if viewModel.isShowingSearchResults {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(Array(viewModel.results), id: \.self) { result in
                            SearchResultsCell(title: result.name,
                                              subtitle: result.domain,
                                              isUniversity: true)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    action(result)
                                    viewModel.clearInput()
                                    isTextFieldFocused = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    UniversitySearchView(viewModel: UniversitySearchViewModel()) { _ in }
}
