//
//  HostMemberType.swift
//  mixer
//
//  Created by Peyton Lyons on 11/6/23.
//

import SwiftUI

struct Privilege: OptionSet {
    let rawValue: Int

    static let viewEvents      = Privilege(rawValue: 1 << 0)
    static let createEvents    = Privilege(rawValue: 1 << 1)
    static let editEvents      = Privilege(rawValue: 1 << 2)
    static let deleteEvents    = Privilege(rawValue: 1 << 3)
    static let manageMembers   = Privilege(rawValue: 1 << 4)
    static let viewAnalytics   = Privilege(rawValue: 1 << 5)
    static let manageSettings  = Privilege(rawValue: 1 << 6)
    static let inviteMembers   = Privilege(rawValue: 1 << 7)
    static let removeMembers   = Privilege(rawValue: 1 << 8)
    static let all: Privilege   = [.viewEvents, .createEvents, .editEvents, .deleteEvents, .manageMembers, .viewAnalytics, .manageSettings, .inviteMembers, .removeMembers]
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
    
    var privileges: Privilege {
        switch self {
        case .member, .vip:
            return [.viewEvents, .viewAnalytics]
        case .planner:
            return [.viewEvents, .viewAnalytics, .createEvents, .editEvents]
        case .moderator:
            return [.viewEvents, .viewAnalytics, .createEvents, .editEvents, .deleteEvents, .manageMembers]
        case .admin:
            return .all
        }
    }
}
