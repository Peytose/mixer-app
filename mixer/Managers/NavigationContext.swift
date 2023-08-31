//
//  NavigationContext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import Foundation

struct NavigationContext {
    let state: NavigationState?
    var selectedEvent: Event?
    var selectedHost: Host?
    var selectedUser: User?
}
