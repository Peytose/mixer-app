//
//  HostSideMenuOption.swift
//  mixer
//
//  Created by Peyton Lyons on 8/15/23.
//

import Foundation

enum HostSideMenuOption: Int, CaseIterable, Identifiable, MenuOption {
    case createEvent
    case manageMembers
    case manageEvents
    case dashboard
//    case settings
    
    var id: Int {
        return self.rawValue
    }
    
    var title: String {
        switch self {
            case .createEvent: return "Create Event"
            case .manageMembers: return "Manage Members"
            case .manageEvents: return "Manage Events"
            case .dashboard: return "Dashboard"
//            case .settings: return "Settings"
        }
    }
    
    var imageName: String {
        switch self {
            case .createEvent: return "calendar.badge.plus"
            case .manageMembers: return "person.2.badge.gearshape.fill"
            case .manageEvents: return "calendar.badge.clock"
            case .dashboard: return "chart.bar.xaxis"
//            case .settings: return "gearshape"
        }
    }
}
