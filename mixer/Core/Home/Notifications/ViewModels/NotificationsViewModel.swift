//
//  NotificationsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class NotificationsViewModel: ObservableObject {
    
    @Published var notifications = [Notification]()
    @Published var availableCategories: [NotificationCategory] = [.all]
    @Published var currentCategory: NotificationCategory = .all
    
    private var groupedNotificationIds: [String: [String]] = [:]
    private let userService = UserService.shared
    private let sharedData = SharedNotificationDataStore.shared
    private var listener: ListenerRegistration?
    private var cellViewModels: [String: NotificationCellViewModel] = [:]
    
    init() {
        fetchNotifications()
    }
    
    deinit {
        listener?.remove() // Detach the listener when the ViewModel is deallocated
    }
    
    
    func updateAvailableCategories() {
        var categories: Set<NotificationCategory> = [.all]
        for notification in notifications {
            categories.insert(notification.type.category)
        }
        self.availableCategories = Array(categories).sorted { $0.rawValue < $1.rawValue }
    }
        
    
    func setCurrentCategory(_ category: NotificationCategory) {
        self.currentCategory = category
    }
    
    
    func viewModelForNotification(_ notification: Notification) -> NotificationCellViewModel {
        if let vm = cellViewModels[notification.id ?? ""] {
            return vm
        } else {
            let vm = NotificationCellViewModel(notification: notification)
            cellViewModels[notification.id ?? ""] = vm
            return vm
        }
    }
    
    static func preparePlannerNotificationBatch(for event: Event,
                                                type: NotificationType,
                                                within batch: WriteBatch) {
        var activePlannerIds: [String] = []

        switch type {
        case .plannerAccepted, .plannerDeclined, .plannerRemoved, .plannerReplaced:
            activePlannerIds = event.activePlannerIds ?? []
        case .plannerInvited, .plannerPendingReminder:
            activePlannerIds = event.pendingPlannerIds ?? []
        case .eventPostedWithoutPlanner, .eventLiked, .eventAutoDeleted, .eventDeletedDueToDecline:
            activePlannerIds = (event.activePlannerIds ?? [])
            if let primaryPlannerId = event.primaryPlannerId, !primaryPlannerId.isEmpty {
                activePlannerIds.append(primaryPlannerId)
            }
        default:
            break
        }
        
        guard !activePlannerIds.isEmpty else { return }
        // Prepare the notifications for each planner
        var documentRefsDataMap: [DocumentReference: [String: Any]] = [:]
        for uid in activePlannerIds {
            guard uid != UserService.shared.user?.id else { continue }
            print("DEBUG: Uid for notification: \(uid)")
            
            let plannerNotificationRef = COLLECTION_NOTIFICATIONS
                .document(uid)
                .collection("user-notifications")
                .document()
            
            documentRefsDataMap.updateValue(prepareNotificationData(toUid: uid,
                                                                    type: type,
                                                                    event: event),
                                            forKey: plannerNotificationRef)
            print("\n\nDEBUG: DATA MAP: \(documentRefsDataMap)\n\n")
        }
        
        // Use the batchUpdate function to send all notifications at once
        batch
            .addBatchUpdate(documentRefsDataMap: documentRefsDataMap)
    }
    
    
    func deleteNotification(notification: Notification) {
        guard let userId = userService.user?.id, let docId = notification.id else { return }
        let userNotificationReference = COLLECTION_NOTIFICATIONS
            .document(userId)
            .collection("user-notifications")
        
        if let count = notification.count, count > 1 {
            let groupKey = "\(notification.type.rawValue)|\(notification.hostId ?? "")|\(notification.eventId ?? "")"
            let documentIdsToDelete = self.groupedNotificationIds[groupKey] ?? []
            
            userNotificationReference
                .batchDelete(documentIDs: documentIdsToDelete) { error in
                    if let error = error {
                        print("DEBUG: Error deleting notification. \(error.localizedDescription)")
                        return
                    }
                    
                    HapticManager.playLightImpact()
                }
        } else {
            userNotificationReference
                .document(docId)
                .delete { error in
                    if let error = error {
                        print("DEBUG: Error deleting notification. \(error.localizedDescription)")
                        return
                    }
                    
                    HapticManager.playLightImpact()
                }
        }
    }

    
    func fetchNotifications() {
        guard let uid = userService.user?.id else {
            print("DEBUG: User ID is nil")
            return
        }
        
        print("DEBUG: Fetching notifications for user ID: \(uid)")
        
        var query = COLLECTION_NOTIFICATIONS
            .document(uid)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)

        listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("DEBUG: Error fetching notifications: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.compactMap({ try? $0.data(as: Notification.self) })
            let sortedNotifications = notifications.sorted(by: { $0.timestamp > $1.timestamp })
            
            DispatchQueue.main.async {
                let groupedNotifications = self.groupNotifications(sortedNotifications)
                self.notifications = self.processGroupedNotifications(groupedNotifications)
                self.updateAvailableCategories()
                self.populateCache()
            }
        }
    }
    
    
    private func groupNotifications(_ notifications: [Notification]) -> [String: [Notification]] {
        var groupedNotifications = [String: [Notification]]()
        
        for notification in notifications {
            // Check if the notification requires action and should not be grouped
            if notification.type.requiresIndividualAttention {
                // Handle action-required notifications separately
                let key = "requiresIndividualAttention|\(notification.id ?? UUID().uuidString)"
                groupedNotifications[key] = [notification]
            } else {
                // Group other notifications
                let key = "\(notification.type.rawValue)|\(notification.hostId ?? "")|\(notification.eventId ?? "")"
                var group = groupedNotifications[key, default: []]
                group.append(notification)
                groupedNotifications[key] = group
                
                if let notificationId = notification.id {
                    self.groupedNotificationIds[key, default: []].append(notificationId)
                }
            }
        }
        
        return groupedNotifications
    }

    
    private func processGroupedNotifications(_ groupedNotifications: [String: [Notification]]) -> [Notification] {
        var processedNotifications = [Notification]()

        for (_, group) in groupedNotifications.sorted(by: { $0.value.first?.timestamp.seconds ?? 0 > $1.value.first?.timestamp.seconds ?? 0 }) {
            let sortedGroup = group.sorted(by: { $0.timestamp.seconds > $1.timestamp.seconds })

            if let mostRecent = sortedGroup.first {
                var combinedNotification = mostRecent

                if sortedGroup.count > 1 {
                    let additionalCount = sortedGroup.count - 1
                    combinedNotification.count = additionalCount
                    
                    let mostRecentUsername = mostRecent.headline
                    let newHeadline: String

                    if sortedGroup.count == 2 {
                        newHeadline = "\(mostRecentUsername) and \(sortedGroup[1].headline)"
                    } else {
                        newHeadline = "\(mostRecentUsername) & \(additionalCount) others"
                    }

                    combinedNotification.headline = newHeadline

                    // Append up to three profileImageUrls with hyphens
                    let imageUrls = sortedGroup.prefix(3).map { $0.imageUrl }
                    combinedNotification.imageUrl = imageUrls.joined(separator: "!!!")
                }

                processedNotifications.append(combinedNotification)
            }
        }

        return processedNotifications
    }
    
    
    static func uploadNotification(toUid uid: String,
                                   type: NotificationType,
                                   host: Host? = nil,
                                   event: Event? = nil) {
        guard let user = UserService.shared.user else { return }
        guard uid != user.id else { return }
        
        let encodedNotification = prepareNotificationData(toUid: uid,
                                                          type: type,
                                                          host: host,
                                                          event: event)
        
        COLLECTION_NOTIFICATIONS
            .document(uid)
            .collection("user-notifications")
            .addDocument(data: encodedNotification)
    }
}

extension NotificationsViewModel {
    private static func prepareNotificationData(toUid uid: String,
                                 type: NotificationType,
                                 host: Host? = nil,
                                 event: Event? = nil) -> [String: Any] {
        guard let user = UserService.shared.user else { fatalError("Current user not found!") }
        
        var imageUrl = ""
        var headline = ""
        
        switch type {
        case .friendRequest, .friendAccepted, .eventLiked, .newFollower, .memberJoined, .guestlistJoined, .plannerInvited, .plannerAccepted, .plannerDeclined, .plannerReplaced, .plannerRemoved, .plannerPendingReminder:
            imageUrl = user.profileImageUrl
            headline = user.username
        case .memberInvited, .guestlistAdded:
            guard let host = host else { fatalError("Host not found!") }
            headline = host.username
            imageUrl = host.hostImageUrl
        case .eventPostedWithoutPlanner, .eventDeletedDueToDecline, .eventAutoDeleted:
            guard let event = event else { fatalError("Event not found!") }
            headline = event.title
            imageUrl = event.eventImageUrl
        }
        
        let timestamp = Timestamp()
        let expiration = Timestamp(date: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date())
        
        let notification = Notification(hostId: host?.id,
                                        eventId: event?.id,
                                        uid: user.id ?? "",
                                        headline: headline,
                                        timestamp: timestamp,
                                        expireAt: expiration,
                                        imageUrl: imageUrl,
                                        type: type)
        
        guard let encodedNotification = try? Firestore.Encoder().encode(notification) else { fatalError("Could not encode notification!") }
        
        return encodedNotification
    }
    
    
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
        let dispatchGroup = DispatchGroup()
        
        // Fetch hosts
        for hostID in ids.hostIDs {
            dispatchGroup.enter() // Enter dispatch group
            COLLECTION_HOSTS.document(hostID).getDocument { (snapshot, error) in
                defer { dispatchGroup.leave() }
                if let host = try? snapshot?.data(as: Host.self) {
                    DispatchQueue.main.async {
                        self.sharedData.hosts[hostID] = host
                    }
                }
            }
        }
        
        // Fetch events
        for eventID in ids.eventIDs {
            dispatchGroup.enter()
            COLLECTION_EVENTS.document(eventID).getDocument { (snapshot, error) in
                defer { dispatchGroup.leave() }
                if let event = try? snapshot?.data(as: Event.self) {
                    DispatchQueue.main.async {
                        self.sharedData.events[eventID] = event
                    }
                }
            }
        }
        
        // Fetch users
        for userID in ids.userIDs {
            dispatchGroup.enter()
            COLLECTION_USERS.document(userID).getDocument { (snapshot, error) in
                defer { dispatchGroup.leave() }
                if let user = try? snapshot?.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.sharedData.users[userID] = user
                    }
                }
            }
        }
        
        // Notify when all fetches are complete
        dispatchGroup.notify(queue: .main) {
            print("DEBUG: Notification sharedData populated!")
            print("DEBUG: sharedData hosts \(self.sharedData.hosts)")
        }
    }
}

// MARK: - Metadata Functions
extension NotificationsViewModel {
    func numberOfNewNotifications() -> Int {
        guard let lastCheckTimestampSeconds = getLastNotificationCheckTimestampSeconds() else {
            print("DEBUG: No last check timestamp found, assuming all notifications are new.")
            return self.notifications.count
        }
        
        print("DEBUG: Last check timestamp (seconds): \(lastCheckTimestampSeconds)")
        
        let newNotifications = self.notifications.filter { notification in
            let notificationTimestampSeconds = Double(notification.timestamp.seconds)
            print("DEBUG: Comparing notification timestamp (\(notificationTimestampSeconds)) with last check timestamp.")
            return notificationTimestampSeconds > lastCheckTimestampSeconds
        }
        
        print("DEBUG: Number of new notifications: \(newNotifications.count)")
        return newNotifications.count
    }

    private func getLastNotificationCheckTimestampSeconds() -> Double? {
        let timestampSeconds = UserDefaults.standard.double(forKey: "LastNotificationCheckTimestampSeconds")
        if timestampSeconds == 0 {
            print("DEBUG: Last notification check timestamp seconds not set in UserDefaults.")
            return nil
        } else {
            print("DEBUG: Retrieved last notification check timestamp seconds from UserDefaults: \(timestampSeconds)")
            return timestampSeconds
        }
    }
    
    func saveCurrentTimestamp() {
        let timestampSeconds = Date().timeIntervalSince1970
        UserDefaults.standard.set(timestampSeconds, forKey: "LastNotificationCheckTimestampSeconds")
        print("DEBUG: Saved current timestamp (seconds) to UserDefaults: \(timestampSeconds)")
    }
}
