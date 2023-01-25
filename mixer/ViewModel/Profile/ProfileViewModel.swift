//
//  ProfileViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var showSettingsView = false
    @Published var showUnfriendAlert = false
    @Published var continueUnfriendFunc = false
    
    init(user: User) {
        self.user = user
        getUserRelationship()
//        fetchUsersStats()
    }
    
    
    func sendFriendRequest() {
        guard let uid = user.id else { return }
        UserService.sendFriendRequest(uid: uid) { _ in
            self.user.relationshiptoUser = .sentRequest
            NotificationsViewModel.uploadNotifications(toUid: uid, type: .follow)
        }
    }
    
    
    func acceptFriendRequest() {
        guard let uid = user.id else { return }
        UserService.acceptFriendRequest(uid: uid) { _ in
            self.user.relationshiptoUser = .friends
            NotificationsViewModel.uploadNotifications(toUid: uid, type: .follow)
        }
    }
    
    
    func cancelFriendRequest() {
        guard let uid = user.id else { return }
        if self.user.relationshiptoUser == .friends { showUnfriendAlert = true }
        
        if continueUnfriendFunc || self.user.relationshiptoUser == .receivedRequest {
            UserService.cancelRequestOrRemoveFriend(uid: uid) { _ in
                self.user.relationshiptoUser = .notFriends
            }
        }
    }
    
    
    func getUserRelationship() {
        guard !user.isCurrentUser else { return }
        guard let uid = user.id else { return }
        
        UserService.getUserRelationship(uid: uid) { relation in
            self.user.relationshiptoUser = relation
        }
    }
    
    
//    func fetchUsersStats() {
//        guard let uid = user.id else { return }
//
//        COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
//            guard let following = snapshot?.documents.count else { return }
//
//            COLLECTION_FRIENDS.document(uid).collection("user-friends").getDocuments { snapshot, _ in
//                guard let followers = snapshot?.documents.count else { return }
//
//                self.user.stats = UserStats(following: following, followers: followers)
//            }
//        }
//    }
}
