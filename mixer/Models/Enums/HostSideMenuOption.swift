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
//            case .analytics: return "Analytics"
//            case .settings: return "Settings"
        }
    }
    
    var imageName: String {
        switch self {
            case .manageGuestlists: return "list.bullet.rectangle"
            case .createEvent: return "calendar.badge.plus"
            case .manageMembers: return "person.2"
//            case .analytics: return "chart.bar.xaxis"
//            case .settings: return "gearshape"
        }
    }
}
