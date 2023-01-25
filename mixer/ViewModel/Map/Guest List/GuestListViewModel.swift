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
    private var listener: ListenerRegistration?

    init(eventUid: String) {
        self.eventUid = eventUid
    }

    func loadUsers() {
        (users, listener) = EventLists.loadUsers(eventUid: eventUid, type: .invite)
    }

    func stopLoading() {
        listener?.remove()
    }
}
