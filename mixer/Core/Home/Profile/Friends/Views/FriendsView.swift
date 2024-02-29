//
//  FriendsView.swift
//  mixer
//
//  Created by Jose Martinez on 2/29/24.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            // If there are no friends and the search text is not empty, show "No results found"
            if viewModel.filteredFriends.isEmpty && !viewModel.searchText.isEmpty {
                Text("No results found for \"\(viewModel.searchText)\"")
                    .foregroundColor(.secondary)
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Centers the text in the ZStack
            } else {
                List(viewModel.filteredFriends) { friend in
                    NavigationLink {
                        ProfileView(user: friend)
                    } label: {
                        ItemInfoCell(title: friend.firstName,
                                     subtitle: "@\(friend.username)",
                                     imageUrl: friend.profileImageUrl)
                    }
                    .listRowBackground(Color.theme.secondaryBackgroundColor)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search friends")
        .navigationBar(title: "Friends", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
        .onAppear {
            viewModel.fetchFriends()
        }
    }
}
