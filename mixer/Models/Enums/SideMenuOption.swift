//
//  SideMenuOption.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import Foundation

enum SideMenuOption: Int, CaseIterable, Identifiable, MenuOption {
    case favorites
    case mixerId
    case settings
    
    var id: Int {
        return self.rawValue
    }
    
    var title: String {
        switch self {
            case .favorites: return "Favorites"
            case .mixerId: return "mixer ID"
            case .settings: return "Settings"
        }
    }
    
    var imageName: String {
        switch self {
            case .favorites: return "heart.fill"
            case .mixerId: return "person.crop.square.filled.and.at.rectangle.fill"
            case .settings: return "gear"
        }
    }
}
