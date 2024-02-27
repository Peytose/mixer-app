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
                            ItemInfoCell(title: result.name,
                                         subtitle: result.domain,
                                         icon: "graduationcap.circle.fill")
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

struct UniversitySearchModalView: View {
    @ObservedObject var viewModel: UniversitySearchViewModel
    @Binding var dismissSheet: Bool
    let action: (University) -> Void
    
    var body: some View {
        NavigationStack {
            List(Array(viewModel.results), id: \.self) { result in
                ItemInfoCell(title: result.name,
                             subtitle: result.domain,
                             icon: "graduationcap.circle.fill")
                .listRowBackground(Color.theme.secondaryBackgroundColor) // Apply to each cell
                .onTapGesture {
                    action(result)
                    viewModel.clearInput()
                    dismissSheet = false
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.theme.backgroundColor) // Apply the regular background color to the list
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Search Universities")
        }
    }
}


//#Preview {
//    UniversitySearchView(viewModel: UniversitySearchViewModel()) { _ in }
//}
