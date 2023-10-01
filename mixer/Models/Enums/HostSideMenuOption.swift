//
//  HostSideMenuOption.swift
//  mixer
//
//  Created by Peyton Lyons on 8/15/23.
//

import Foundation

enum HostSideMenuOption: Int, CaseIterable, Identifiable, MenuOption {
    case manageGuestlists
    case createEvent
    case manageMembers
    case manageEvents
//    case analytics
//    case settings
    
    var id: Int {
        return self.rawValue
    }
    
    var title: String {
        switch self {
            case .manageGuestlists: return "Manage Guestlists"
            case .createEvent: return "Create Event"
            case .manageMembers: return "Manage Members"
        case .manageEvents: return "Manage Events"
//            case .analytics: return "Analytics"
//            case .settings: return "Settings"
        }
    }
    
    var imageName: String {
        switch self {
            case .manageGuestlists: return "list.bullet.rectangle.fill"
            case .createEvent: return "calendar.badge.plus"
            case .manageMembers: return "person.2.badge.gearshape.fill"
            case .manageEvents: return "calendar.badge.clock"
//            case .analytics: return "chart.bar.xaxis"
//            case .settings: return "gearshape"
        }
    }
}
