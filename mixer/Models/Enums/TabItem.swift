//
//  TabItem.swift
//  mixer
//
//  Created by Peyton Lyons on 8/17/23.
//

import SwiftUI
import TabBar

enum TabItem: Int, CaseIterable, Equatable {
    case map
    case explore
    case search
    
    var icon: String {
        switch self {
            case .map: return "map"
            case .explore: return "music.note.house"
            case .search: return "magnifyingglass"
        }
    }
    
    var title: String {
        switch self {
            case .map: return "Map"
            case .explore: return "Explore"
            case .search: return "Search"
        }
    }
}
