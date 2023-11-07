//
//  HostMemberType.swift
//  mixer
//
//  Created by Peyton Lyons on 11/6/23.
//

import SwiftUI

enum PrivilegeLevel: Int {
    case basic
    case advanced
    case admin
}

enum HostMemberType: Int, CustomStringConvertible, Codable, CaseIterable {
    case member
    case planner
    case vip
    case moderator
    case admin

    var description: String {
        switch self {
        case .member:
            return "Member"
        case .planner:
            return "Planner"
        case .vip:
            return "VIP"
        case .moderator:
            return "Moderator"
        case .admin:
            return "Admin"
        }
    }
    
    var privilege: PrivilegeLevel {
        switch self {
        case .member:
            return .basic
        case .planner, .vip:
            return .advanced
        case .moderator, .admin:
            return .admin
        }
    }
}
