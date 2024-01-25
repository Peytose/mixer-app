//
//  Notification.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import FirebaseFirestoreSwift
import FirebaseFirestore
import Firebase

struct Notification: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var hostId: String?
    var eventId: String?
    let uid: String
    let headline: String
    let timestamp: Timestamp
    var expireAt: Timestamp
    let imageUrl: String
    var type: NotificationType
    
    var isFollowed: Bool? = false
    var isFriends: Bool? = false
    var event: Event?
    var user: User?
    var host: Host?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uid)
        hasher.combine(headline)
        // You can add other properties if needed.
    }
}

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
    
    var notificationMessage: String {
        switch self {
            case .friendRequest: return " sent you a friend request."
            case .friendAccepted: return " is now your friend!"
            case .eventLiked: return " liked "
            case .newFollower: return " started following you!"
            case .memberInvited: return " invited you to join "
            case .memberJoined: return " joined "
            case .guestlistJoined: return " joined the guestlist for "
            case .guestlistAdded: return " added you to the guestlist for "
            case .plannerInvited: return " has invited you to be a planner for "
            case .plannerAccepted: return " has confirmed "
            case .plannerDeclined: return " has declined "
            case .plannerReplaced: return " has been replaced as a planner for "
            case .plannerRemoved: return " has been removed as a planner for "
            case .plannerPendingReminder: return " is reminding you to confirm your participation in "
            case .eventPostedWithoutPlanner: return " has been posted without a planner."
            case .eventDeletedDueToDecline: return " was deleted due to a planner's decline."
            case .eventAutoDeleted: return " was automatically deleted due to pending confirmations."
        }
    }
}

