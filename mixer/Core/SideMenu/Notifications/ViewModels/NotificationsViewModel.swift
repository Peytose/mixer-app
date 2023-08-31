//
//  NotificationsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import Firebase

class NotificationsViewModel: ObservableObject {
    @Published var notifications = [Notification]()
    @Published var cache = NotificationCache()
    
    private let service = UserService.shared
    private var lastDocument: DocumentSnapshot?
    private var listener: ListenerRegistration?
    
    init() {
        fetchNotifications()
    }

    deinit {
        listener?.remove() // Detach the listener when the ViewModel is deallocated
    }

    
    func fetchNotifications() {
        guard let uid = service.user?.id else { return }
        
        var query = COLLECTION_NOTIFICATIONS
            .document(uid)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)
            .limit(to: 10) // Set the page size

        // If there's a last document, start the query from there
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        listener = query.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.compactMap({ try? $0.data(as: Notification.self) })
            let sortedNotifications = notifications.sorted(by: { $0.timestamp > $1.timestamp })
            
            self.notifications = sortedNotifications
            self.populateCache()
            self.lastDocument = documents.last // Update the last document for the next page
        }
    }

    
    // Call this method to fetch the next page of notifications
    func fetchNextPage() {
        fetchNotifications()
    }
    
    
    static func uploadNotification(toUid uid: String,
                                   type: NotificationType,
                                   host: Host? = nil,
                                   event: Event? = nil) {
        guard let user = UserService.shared.user else { return }
//        guard uid != user.id else { return }
        
        var imageUrl = ""
        var username = ""
        
        switch type {
        case .friendRequest,
                .friendAccepted,
                .eventLiked,
                .newFollower,
                .memberJoined,
                .guestlistJoined:
            imageUrl = user.profileImageUrl
            username = user.username
        case .memberInvited,
                .guestlistAdded:
            guard let host = host else { return }
            username = host.username
            imageUrl = host.hostImageUrl
        }
        
        let notification = Notification(hostId: host?.id,
                                        eventId: event?.id,
                                        uid: user.id ?? "",
                                        username: username,
                                        timestamp: Timestamp(),
                                        imageUrl: imageUrl,
                                        type: type)
        
        guard let encodedNotification = try? Firestore.Encoder().encode(notification) else { return }
        
        COLLECTION_NOTIFICATIONS
            .document(uid)
            .collection("user-notifications")
            .addDocument(data: encodedNotification)
    }
}

extension NotificationsViewModel {
    private func gatherUniqueIDs() -> (hostIDs: Set<String>, eventIDs: Set<String>, userIDs: Set<String>) {
        var hostIDs = Set<String>()
        var eventIDs = Set<String>()
        var userIDs = Set<String>()
        
        for notification in notifications {
            if let hostID = notification.hostId { hostIDs.insert(hostID) }
            if let eventID = notification.eventId { eventIDs.insert(eventID) }
            userIDs.insert(notification.uid)
        }
        
        return (hostIDs, eventIDs, userIDs)
    }
    
    private func populateCache() {
        let ids = gatherUniqueIDs()
        
        // Fetch hosts
        for hostID in ids.hostIDs {
            COLLECTION_HOSTS.document(hostID).getDocument { snapshot, _ in
                if let host = try? snapshot?.data(as: Host.self) {
                    self.cache.hosts[hostID] = host
                    
                    // Update the host value in the notifications array
                    self.notifications = self.notifications.map { notification in
                        if notification.hostId == hostID {
                            var updatedNotification = notification
                            updatedNotification.host = host
                            return updatedNotification
                        }
                        return notification
                    }
                }
            }
        }
        
        // Fetch events
        for eventID in ids.eventIDs {
            COLLECTION_EVENTS.document(eventID).getDocument { snapshot, _ in
                if let event = try? snapshot?.data(as: Event.self) {
                    self.cache.events[eventID] = event
                    
                    // Update the event value in the notifications array
                    self.notifications = self.notifications.map { notification in
                        if notification.eventId == eventID {
                            var updatedNotification = notification
                            updatedNotification.event = event
                            return updatedNotification
                        }
                        return notification
                    }
                }
            }
        }
        
        // Fetch users
        for userID in ids.userIDs {
            COLLECTION_USERS.document(userID).getDocument { snapshot, _ in
                if let user = try? snapshot?.data(as: User.self) {
                    self.cache.users[userID] = user
                    
                    // Update the user value in the notifications array
                    self.notifications = self.notifications.map { notification in
                        if notification.uid == userID {
                            var updatedNotification = notification
                            updatedNotification.user = user
                            return updatedNotification
                        }
                        return notification
                    }
                }
            }
        }
    }

}
