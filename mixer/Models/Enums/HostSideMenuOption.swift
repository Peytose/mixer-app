//
//  HostSideMenuOption.swift
//  mixer
//
//  Created by Peyton Lyons on 8/15/23.
//

import Foundation

enum HostSideMenuOption: Int, CaseIterable, Identifiable, MenuOption {
    case dashboard
//    case settings
    
    var id: Int {
        return self.rawValue
    }
    
    var title: String {
        switch self {
            case .dashboard: return "Dashboard"
//            case .settings: return "Settings"
        }
    }
    
    var imageName: String {
        switch self {
            case .dashboard: return "chart.bar.xaxis"
//            case .settings: return "gearshape"
        }
    }
}
