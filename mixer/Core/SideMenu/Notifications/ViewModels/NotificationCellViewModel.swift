//
//  NotificationCellViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import Firebase

class NotificationCellViewModel: ObservableObject {
    @Published var notification: Notification
    private let userService = UserService.shared
    private let hostService = HostService.shared
    
    init(notification: Notification) {
        self.notification = notification
        checkUserRelationship()
    }
    
    
    func formattedNotificationMessage() -> Text {
        var message = Text("@\(notification.username)")
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(Color.theme.mixerIndigo)

        message = message + Text(notification.type.notificationMessage)
            .font(.subheadline)
            .foregroundColor(.white)
        
        switch notification.type {
            case .eventLiked,
                    .guestlistJoined,
                    .guestlistAdded:
                if let event = notification.event {
                    message = message + Text(event.title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            case .memberInvited,
                    .memberJoined:
                if let host = notification.host {
                    message = message + Text(host.name)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            default: break
        }

        return message + Text(" \(notification.timestampString)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    
    func declineMemberInvite() {
        if let hostId = notification.hostId, let memberId = userService.user?.id {
            userService.rejectMemberInviteOrRemove(fromHost: hostId,
                                                   fromUser: notification.uid,
                                                   memberId: memberId) { _ in
                HapticManager.playLightImpact()
            }
        }
    }
    
    
    func acceptMemberInvite() {
        print("Host: \(String(describing: notification.host))")
        print("Event: \(String(describing: notification.event))")
        if let host = notification.host {
            userService.acceptMemberInvite(forHost: host, fromUser: notification.uid) { _ in
                HapticManager.playSuccess()
            }
        } else {
            print("Host is nil")
        }
    }
    
    
    func deleteNotification() {
        guard let notificationId = notification.id,
              let userId = userService.user?.id else { return }
        
        COLLECTION_NOTIFICATIONS
            .document(userId)
            .collection("user-notifications")
            .document(notificationId)
            .delete { _ in
                HapticManager.playLightImpact()
            }
    }

    
    
    func removeFromGuestlist() {
        if let eventId = notification.eventId {
            hostService.removeUserFromGuestlist(with: notification.uid,
                                                eventId: eventId) { _ in
                HapticManager.playSuccess()
            }
        }
    }
    
    
    func acceptFriendRequest() {
        userService.acceptFriendRequest(uid: notification.uid) { _ in
            HapticManager.playSuccess()
        }
    }
    
    
    func cancelRequestOrRemoveFriend() {
        userService.cancelRequestOrRemoveFriend(uid: notification.uid) { _ in
            HapticManager.playLightImpact()
        }
    }
    
    
    func checkUserRelationship() {
        guard notification.type == .friendRequest
                || notification.type == .friendAccepted
                || notification.type == .newFollower else { return }
        
        UserService.shared.getUserRelationship(uid: notification.uid) { state in
            switch state {
            case .friends:
                self.notification.isFriends = true
            default:
                self.notification.isFriends = false
            }
        }
    }
}
