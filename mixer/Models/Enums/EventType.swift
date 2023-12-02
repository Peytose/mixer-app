//
//  EventType.swift
//  mixer
//
//  Created by Peyton Lyons on 11/21/23.
//

import SwiftUI

enum EventType: Int, Codable, CaseIterable {
    case school
    case club
    case party
    case mixer
    case rager
    case darty
    case kickback
    
    var description: String {
        switch self {
            case .school: return "School event"
            case .club: return "Club event"
            case .party: return "Party"
            case .mixer: return "Mixer"
            case .rager: return "Rager"
            case .darty: return "Darty"
            case .kickback: return "Kickback"
        }
    }
}
