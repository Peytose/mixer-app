//
//  TabItem.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import SwiftUI
import TabBar

enum TabItem: Int, Equatable {
    case map
    case explore
    case dashboard
    case profile
//    case inbox
    
    var icon: String {
        switch self {
            case .map: return "map"
            case .explore: return "person.3"
            case .dashboard: return "house"
            case .profile: return "circle"
        }
    }
    
    var title: String {
        switch self {
            case .map: return "Map"
            case .explore: return "Explore"
            case .dashboard: return "Dashboard"
            case .profile: return "Profile"
        }
    }

    static func availableTabs() -> [TabItem] {
        var tabs: [TabItem] = [.map, .explore, .profile]
        if !(UserService.shared.user?.hostIdToMemberTypeMap?.isEmpty ?? true) {
            tabs.insert(.dashboard, at: 2) // Adjust the index based on where you want to insert the add tab
        }
        return tabs
    }
}
