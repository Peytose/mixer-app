//
//  RelationshipState.swift
//  mixer
//
//  Created by Peyton Lyons on 9/3/23.
//

import SwiftUI

enum RelationshipState: Int, Codable, IconRepresentable {
    case friends
    case requestSent
    case requestReceived
    case notFriends
    case blocked

    var text: String {
        switch self {
            case .friends: return "Friends"
            case .requestSent: return "Request Sent"
            case .requestReceived: return "Accept Request"
            case .notFriends: return "Send Request"
            case .blocked: return "Unblock"
        }
    }
    
    var icon: String {
        switch self {
            case .friends: return "person.2.fill"
            case .requestSent: return "person.wave.2.fill"
            case .requestReceived: return "person.fill.checkmark"
            case .notFriends: return "person.fill.badge.plus"
            case .blocked: return "person.crop.circle.badge.exclamationmark.fill"
        }
    }
}
