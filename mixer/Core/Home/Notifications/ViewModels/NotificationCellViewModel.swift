//
//  NotificationCellViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 2/3/24.
//

import SwiftUI
import FirebaseFirestore

class NotificationCellViewModel: ObservableObject {
    
    @Published var notification: Notification
    
    private let userService = UserService.shared
    private let hostService = HostService.shared
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    
    func removePlanner(event: Event?) {
        guard let event = event else { return }
        userService.handlePlannerAction(forEvent: event,
                                        actionType: .plannerRemoved) { _ in
            HapticManager.playLightImpact()
        }
    }
    
    
    func acceptPlannerInvite(event: Event?) {
        guard let event = event else { return }
        userService.handlePlannerAction(forEvent: event,
                                        actionType: .plannerAccepted) { _ in
            HapticManager.playLightImpact()
        }
    }
    
    
    func declinePlannerInvite(event: Event?) {
        guard let event = event else { return }
        userService.handlePlannerAction(forEvent: event,
                                        actionType: .plannerDeclined) { _ in
            HapticManager.playLightImpact()
        }
    }
    
    
    func declineMemberInvite() {
        if let hostId = notification.hostId,
           let memberId = userService.user?.id {
            userService.rejectMemberInvite(fromUser: notification.uid,
                                           fromHost: hostId,
                                           memberId: memberId) { _ in
                HapticManager.playLightImpact()
            }
        }
    }
    
    
    func acceptMemberInvite(host: Host?) {
        if let host = host {
            userService.acceptMemberInvite(forHost: host,
                                           fromUser: notification.uid) { _ in
                HapticManager.playSuccess()
            }
        } else {
            print("Host is nil")
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
        guard let notificationId = notification.id else { return }
        
        userService.acceptFriendRequest(uid: notification.uid) { _ in
            guard let userId = self.userService.user?.id else { return }
            
            COLLECTION_NOTIFICATIONS
                .updateNotification(forUserID: userId,
                                    notificationID: notificationId,
                                    updatedData: ["timestamp": Timestamp(),
                                                  "type": NotificationType.friendAccepted.rawValue]) { error in
                    if let error = error {
                        print("DEBUG: Error updating notification. \(error.localizedDescription)")
                        return
                    }
                    
                    self.notification.type = .friendAccepted
                    HapticManager.playSuccess()
                }
        }
    }
    
    
    func cancelOrDeleteRelationship() {
        userService.cancelOrDeleteRelationship(uid: notification.uid) { _ in
            HapticManager.playLightImpact()
        }
    }
    
    
    func checkUserRelationship() {
        guard notification.type == .friendRequest || notification.type == .friendAccepted || notification.type == .newFollower else { return }
        
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
