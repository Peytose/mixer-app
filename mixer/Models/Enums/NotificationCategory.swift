//
//  NotificationCategory.swift
//  mixer
//
//  Created by Peyton Lyons on 2/2/24.
//

import SwiftUI

enum NotificationCategory: Int, CaseIterable {
    case all
    case follows
    case likes
    case friends
    case membership
    case guestlist
    case eventPlanning
    case eventUpdates
    // Additional categories as necessary
    
    var stringVal: String {
        switch self {
        case .all: return "All activity"
        case .follows: return "Follows"
        case .likes: return "Likes"
        case .friends: return "Friends"
        case .membership: return "Membership"
        case .guestlist: return "Guestlist"
        case .eventPlanning: return "Planning"
        case .eventUpdates: return "Updates"
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "bell"
        case .follows: return "person"
        case .likes: return "heart"
        case .friends: return "figure.2.arms.open"
        case .membership: return "building.columns"
        case .guestlist: return "list.bullet.rectangle"
        case .eventPlanning: return "calendar"
        case .eventUpdates: return "megaphone"
        }
    }
}
