//
//  ProfileViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import Firebase

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var showSettingsView     = false
    @Published var showUnfriendAlert    = false
    @Published var isShowingMoreProfileOptions = false
    @Published var continueUnfriendFunc = false
    @Published var favoritedEvents      = [Event]()
    @Published var pastEvents           = [Event]()
    @Published var mutuals              = [User]()
    
    @Published var currentAlert: AlertType?
    @Published var alertItem: AlertItem? {
        didSet {
            currentAlert = .regular(alertItem)
        }
    }
    @Published var confirmationAlertItem: ConfirmationAlertItem? {
        didSet {
            currentAlert = .confirmation(confirmationAlertItem)
        }
    }
    
    private var service = UserService.shared
    private var hostManager = HostManager.shared
    
    init(user: User) {
        self.user = user
        self.getUserRelationship()
        
        if let associatedHostIds = user.associatedHostIds,
           !associatedHostIds.isEmpty,
           user.accountType == .host || user.accountType == .member {
            hostManager.fetchHosts(with: associatedHostIds) { hosts in
                self.user.associatedHosts = hosts
            }
        }
        
        if user.university == nil {
            service.fetchUniversity(with: user.universityId) { university in
                self.user.university = university
            }
        }
    }
    
    
    @MainActor func sendFriendRequest() {
        guard let uid = user.id else { return }
        UserService.shared.sendFriendRequest(username: user.username, uid: uid) { _ in
            self.user.relationshipState = .requestSent
            HapticManager.playSuccess()
        }
    }
    
    
    @MainActor func acceptFriendRequest() {
        guard let uid = user.id else { return }
        UserService.shared.acceptFriendRequest(uid: uid) { _ in
            self.user.relationshipState = .friends
            
            guard let currentUserId = UserService.shared.user?.id else { return }
            
            COLLECTION_NOTIFICATIONS
                .deleteNotifications(forUserID: currentUserId,
                                     ofTypes: [.friendRequest],
                                     from: uid) { _ in
                    HapticManager.playSuccess()
                }
        }
    }
    
    
    @MainActor func cancelRelationshipRequest() {
        guard let uid = user.id else { return }
        guard let state = user.relationshipState else { return }
        
        switch state {
        case .friends:
            self.confirmationAlertItem = AlertContext.confirmRemoveFriend {
                UserService.shared.cancelOrDeleteRelationship(uid: uid) { _ in
                    self.user.relationshipState = .notFriends
                    HapticManager.playLightImpact()
                }
            }
        case .requestReceived, .requestSent, .blocked:
            UserService.shared.cancelOrDeleteRelationship(uid: uid) { _ in
                self.user.relationshipState = .notFriends
                HapticManager.playLightImpact()
            }
        default: break
        }
    }
    
    
    func getUserRelationship() {
        guard !user.isCurrentUser else {
            print("DEBUG: This is the current user's profile!")
            return
        }
        
        guard let uid = user.id else { return }
        
        UserService.shared.getUserRelationship(uid: uid) { relation in
            self.user.relationshipState = relation
            print("DEBUG: relation to user. \(relation)")
        }
    }
    
    
    func blockUser() {
        confirmationAlertItem = AlertContext.confirmBlock(name: user.displayName) {
            self.service.blockUser(self.user) { _ in
                self.user.relationshipState = .blocked
                self.isShowingMoreProfileOptions = false
                HapticManager.playSuccess()
            }
        }
    }
}
