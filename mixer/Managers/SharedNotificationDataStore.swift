//
//  SharedNotificationDataStore.swift
//  mixer
//
//  Created by Peyton Lyons on 8/24/23.
//

import SwiftUI

class SharedNotificationDataStore: ObservableObject {
    @Published var hosts: [String: Host] = [:]
    @Published var events: [String: Event] = [:]
    @Published var users: [String: User] = [:]
    
    static let shared = SharedNotificationDataStore()
}
