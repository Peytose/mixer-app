//
//  FriendsViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 2/29/24.
//

import SwiftUI
import Combine


class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var filteredFriends: [User] = []
    @Published var isLoading = false
    @Published var searchText = "" {
        didSet {
            self.search(userService.friends)
        }
    }
    
    private var userService = UserService.shared
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        self.fetchFriends()
    }
    
    
    func fetchFriends() {
        userService.$friends
            .sink { friends in
                self.friends = friends
            }
            .store(in: &cancellable)
    }

    
    private func search(_ friends: [User]) {
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
