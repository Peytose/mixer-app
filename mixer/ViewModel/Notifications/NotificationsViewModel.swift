//
//  NotificationsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import Firebase

class NotificationsViewModel: ObservableObject {
    @Published var notifications = [Notification]()
    
    init() {
        fetchNotifications()
    }
    
    
    private static func cacheUser(user: CachedUser) {
        Task {
            do {
                try UserCache.shared.cacheUser(user)
            } catch {
                print("DEBUG: Error caching user for notification. \(error.localizedDescription)")
            }
        }
    }
    
    
    func fetchNotifications() {
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        
        let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, _ in
            Task {
                do {
                    guard let documents = snapshot?.documents else { return }
                    var notifications = [Notification]()
                    
                    // Create a dispatch group
                    let group = DispatchGroup()
                    
                    for document in documents {
                        group.enter()
                        
                        if var notification = try? document.data(as: Notification.self) {
                            // Fetch the user from the uid
                            notification.user = try await UserCache.shared.getUser(withId: notification.uid)
                            notifications.append(notification)
                            group.leave()
                        } else {
                            group.leave()
                        }
                    }
                    
                    // Notify the completion of all tasks in the dispatch group
                    group.notify(queue: .main) {
                        self.notifications = notifications.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
                    }
                } catch {
                    print("DEBUG: Error fetching notifications. \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    static func cancelFriendRequest(notification: Notification) {
        UserService.cancelRequestOrRemoveFriend(uid: notification.uid) { _ in
            guard var user = notification.user else { return }
            user.relationshiptoUser = .notFriends
            self.cacheUser(user: user)
            
            HapticManager.playLightImpact()
        }
    }
    
    
    static func acceptFriendRequest(notification: Notification, completion: @escaping() -> Void) {
        UserService.acceptFriendRequest(uid: notification.uid) { _ in
            guard var user = notification.user else { return }
            user.relationshiptoUser = .friends
            self.cacheUser(user: user)
            
            NotificationsViewModel.uploadNotifications(toUid: notification.uid, type: .acceptFriend)
            HapticManager.playLightImpact()
            
            completion()
        }
    }
    
    
    static func uploadNotifications(toUid uid: String, type: NotificationType) {
        guard let user = AuthViewModel.shared.currentUser else { return }
        guard uid != user.id else { return }
        
        var data = ["timestamp": Timestamp(date: Date()),
                    "username": user.username,
                    "uid": user.id ?? "",
                    "profileImageUrl": user.profileImageUrl,
                    "type": type.rawValue] as [String: Any]
        
//        if let post = post, let id = post.id {
//            data["postId"] = id
//        }
        
        COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").addDocument(data: data)
    }
}
