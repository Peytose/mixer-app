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
    case requestToJoin
    case pendingJoinRequest
    case open
    case inviteOnly
    
    init(event: Event) {
        if event.endDate < Timestamp() {
            self = .pastEvent
        } else if event.didGuestlist ?? false {
            self = .onGuestlist
        } else if event.isInviteOnly {
            self = .inviteOnly
        } else if event.isManualApprovalEnabled {
            if event.didRequest ?? false {
                self = .pendingJoinRequest
            } else {
                self = .requestToJoin
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
        case .requestToJoin:
            return "Request"
        case .pendingJoinRequest:
            return "Cancel"
        case .open:
            return "Join"
        default:
            return ""
        }
    }
    
    var eventDetailText: String {
        switch self {
        case .onGuestlist:
            return "Leave Guestlist"
        case .requestToJoin:
            return "Request to Join"
        case .pendingJoinRequest:
            return "Cancel Request"
        case .open:
            return "Join Guestlist"
        default:
            return ""
        }
    }
    
    var icon: String {
        switch self {
        case .pastEvent:
            return "trash.fill"
        case .onGuestlist:
            return "person.crop.circle.badge.checkmark"
        case .requestToJoin:
            return "person.badge.plus.fill"
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
        case .pastEvent, .onGuestlist, .pendingJoinRequest:
            return true
        case .requestToJoin, .open:
            return false
        default:
            return true
        }
    }
}
