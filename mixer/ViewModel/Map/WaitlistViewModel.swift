//
//  WaitlistViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase

final class WaitlistViewModel: ObservableObject {
    @Published var users = [User]()
    private let eventUid: String
    private var listener: ListenerRegistration?

    init(eventUid: String) {
        self.eventUid = eventUid
    }

    @MainActor func loadUsers() {
        self.users = EventLists.loadUsers(eventUid: eventUid, type: .invite)
    }
}
