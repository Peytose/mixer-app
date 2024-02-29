//
//  FriendsViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 2/29/24.
//

import Foundation

class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var filteredFriends: [User] = []
    @Published var isLoading = false
    @Published var searchText = "" {
        didSet {
            searchFriends()
        }
    }

    private var userService = UserService.shared

    func fetchFriends() {
        isLoading = true
        userService.fetchFriends { [weak self] users in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.friends = users
                self?.filteredFriends = users
            }
        }
    }

    private func searchFriends() {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter { user in
                user.firstName.lowercased().contains(searchText.lowercased()) ||
                user.username.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
