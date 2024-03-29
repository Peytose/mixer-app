//
//  EventUserActionState.swift
//  mixer
//
//  Created by Peyton Lyons on 9/10/23.
//

import SwiftUI
import FirebaseFirestore

enum EventUserActionState {
    case pastEvent
    case onGuestlist
    case pendingJoinRequest
    case open
    case inviteOnly
    
    init(event: Event) {
        if event.endDate < Timestamp() {
            self = .pastEvent
        } else if event.didGuestlist ?? false {
            self = .onGuestlist
        } else if event.isInviteOnly {
            if event.didRequest ?? false {
                self = .pendingJoinRequest
            } else {
                self = .inviteOnly
            }
        } else {
            self = .open
        }
    }
    
    var favoriteText: String {
        switch self {
        case .pastEvent:
            return "Remove"
        case .onGuestlist:
            return "Leave"
        case .inviteOnly:
            return "Request"
        case .pendingJoinRequest:
            return "Cancel"
        case .open:
            return "Join"
        }
    }
    
    var eventDetailText: String {
        switch self {
        case .pastEvent:
            return "Event Ended"
        case .onGuestlist:
            return "Leave Guestlist"
        case .inviteOnly:
            return "Request to Join"
        case .pendingJoinRequest:
            return "Cancel Request"
        case .open:
            return "Join Guestlist"
        }
    }
    
    var icon: String {
        switch self {
        case .pastEvent:
            return "trash.fill"
        case .onGuestlist:
            return "person.crop.circle.badge.checkmark"
        case .pendingJoinRequest:
            return "hourglass"
        case .open:
            return "list.clipboard.fill"
        case .inviteOnly:
            return "lock.shield.fill"
        }
    }
    
    var isSecondaryLabel: Bool {
        switch self {
        case .open:
            return false
        default:
            return true
        }
    }
}
