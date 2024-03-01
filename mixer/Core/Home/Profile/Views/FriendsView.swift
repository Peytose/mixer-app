//
//  FriendsView.swift
//  mixer
//
//  Created by Jose Martinez on 2/29/24.
//

import SwiftUI

struct FriendsView: View {
    @ObservedObject var viewModel: FriendsViewModel
    var navigationTitle: String = "Friends"

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            // If there are no friends and the search text is not empty, show "No results found"
            if viewModel.filteredFriends.isEmpty && !viewModel.searchText.isEmpty {
                Text("No results found for \"\(viewModel.searchText)\"")
                    .foregroundColor(.secondary)
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List(viewModel.searchText.isEmpty ? viewModel.friends : viewModel.filteredFriends) { friend in
                    NavigationLink {
                        ProfileView(user: friend)
                    } label: {
                        ItemInfoCell(title: friend.firstName,
                                     subtitle: "@\(friend.username)",
                                     imageUrl: friend.profileImageUrl,
                                     university: friend.university)
                    }
                    .listRowBackground(Color.theme.secondaryBackgroundColor)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search \(navigationTitle.lowercased())")
        .navigationBar(title: navigationTitle, displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
    }
}
