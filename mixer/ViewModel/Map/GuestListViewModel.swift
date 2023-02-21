//
//  InviteListViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase

final class InviteListViewModel: ObservableObject {
    @Published var users = [User]()
    private let eventUid: String
    
    init(eventUid: String) {
        self.eventUid = eventUid
        loadUsers()
    }

    private func loadUsers() {
        self.users = EventLists.loadUsers(eventUid: eventUid, type: .invite)
    }
}
