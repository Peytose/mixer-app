//
//  MapItemType.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import Foundation

enum MapItemType: Int, CustomStringConvertible, CaseIterable {
    case event
    case host
    
    var description: String {
        switch self {
            case .event: return "Events"
            case .host: return "Hosts"
        }
    }
}
