//
//  SearchType.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import Foundation

enum SearchType: Int, CustomStringConvertible, CaseIterable {
    case events
    case hosts
    case users
    
    var description: String {
        switch self {
        case .events: return "Events"
        case .hosts: return "Hosts"
        case .users: return "Users"
        }
    }
}
