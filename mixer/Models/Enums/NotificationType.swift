//
//  NotificationType.swift
//  mixer
//
//  Created by Peyton Lyons on 2/4/24.
//

import SwiftUI

enum NotificationType: Int, Codable {
    case friendRequest // User receives a friend request from another user
    case friendAccepted // User's friend request has been accepted by another user
    case eventLiked // User's event has been liked by another user
    case newFollower // User has a new follower
    case memberInvited // User has been invited to join an event or group
    case memberJoined // A user has joined an event or group that the current user is part of
    case guestlistJoined // A user has joined the guestlist for an event
    case guestlistAdded // User has been added to the guestlist for an event
    case plannerInvited // A user has been invited to be a planner for an event
    case plannerAccepted // A planner has confirmed their participation in an event
    case plannerDeclined // A planner has declined their participation in an event
    case plannerReplaced // A planner has been replaced by another planner for an event
    case plannerRemoved // A planner has been removed from an event
    case plannerPendingReminder // A reminder for planners who haven't confirmed their participation yet
    case eventPostedWithoutPlanner // An event has been posted without one or more planners
    case eventDeletedDueToDecline // An event was deleted because a planner declined and no action was taken
    case eventAutoDeleted // An event was automatically deleted due to unconfirmed planners after the start date
    
    var category: NotificationCategory {
            switch self {
            case .friendRequest, .friendAccepted:
                return .friends // Includes friend requests and acceptances
            case .eventLiked:
                return .likes // Includes likes and other forms of engagement with content
            case .newFollower:
                return .follows // New followers, mentions, etc.
            case .memberInvited, .memberJoined:
                return .membership // Invitations to join and confirmations of joining
            case .guestlistJoined, .guestlistAdded:
                return .guestlist // Notifications related to the management of event guestlists
            case .plannerInvited, .plannerAccepted, .plannerDeclined, .plannerReplaced, .plannerRemoved, .plannerPendingReminder:
                return .eventPlanning // Notifications related to the planning and management of events
            case .eventPostedWithoutPlanner, .eventDeletedDueToDecline, .eventAutoDeleted:
                return .eventUpdates // Notifications about events being posted, deleted, or automatically removed
            }
        }
    
    var requiresIndividualAttention: Bool {
        switch self {
        case .friendRequest, .memberInvited, .guestlistJoined, .plannerInvited, .plannerDeclined, .plannerReplaced, .plannerPendingReminder, .eventPostedWithoutPlanner, .eventDeletedDueToDecline, .eventAutoDeleted:
                return true
            default:
                return false
        }
    }
    
    func notificationMessage(_ count: Int? = nil) -> String {
        let isPlural = (count ?? 1) > 1
        
        switch self {
            case .friendRequest: return " sent you a friend request."
            case .friendAccepted: return (isPlural ? " are" : " is") + " now your friend!"
            case .eventLiked: return " liked "
            case .newFollower: return " started following you!"
            case .memberInvited: return " invited you to join "
            case .memberJoined: return " joined "
            case .guestlistJoined: return " joined the guestlist for "
            case .guestlistAdded: return " added you to the guestlist for "
            case .plannerInvited: return " has invited you to be a planner for "
            case .plannerAccepted: return (isPlural ? " have" : " has") + " confirmed "
            case .plannerDeclined: return " has declined "
            case .plannerReplaced: return " has been replaced as a planner for "
            case .plannerRemoved: return (isPlural ? " have" : " has") + " been removed as a planner for "
            case .plannerPendingReminder: return " is reminding you to confirm your participation in "
            case .eventPostedWithoutPlanner: return " has been posted without a planner."
            case .eventDeletedDueToDecline: return " was deleted due to a planner's decline."
            case .eventAutoDeleted: return " was automatically deleted due to pending confirmations."
        }
    }
}
