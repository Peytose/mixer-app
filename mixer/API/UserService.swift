//
//  UserService.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

typealias FirestoreCompletion = ((Error?) -> Void)?

class UserService: ObservableObject {
    static let shared = UserService()
    @Published var user: User?
    
    private var listener: ListenerRegistration?
    
    init() {
        fetchUser()
    }
    
    deinit {
        listener?.remove()
    }
    
    
    func fetchUser() {
        if listener != nil { listener?.remove() }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user.")
            return
        }
        
        self.listener = COLLECTION_USERS
            .document(uid)
            .addSnapshotListener { snapshot, error in
                print("DEBUG: Did fetch user from firestore.")
                guard let user = try? snapshot?.data(as: User.self) else { return }
                self.user = user
                
                if !(user.hostIdToMemberTypeMap?.isEmpty ?? true) {
                    print("DEBUG: Fetching hosts...")
                    self.fetchAssociatedHosts()
                }
                
                if user.university == nil {
                    self.fetchUniversity(with: user.universityId) { university in
                        self.user?.university = university
                    }
                }
            }
    }

    
    private func fetchAssociatedHosts() {
        guard let hostIds = user?.hostIdToMemberTypeMap?.keys else { return }
        
        HostManager.shared.fetchHosts(with: Array(hostIds)) { hosts in
            let sortedHosts = hosts.sorted(by: { $0.name < $1.name })
            self.user?.associatedHosts = sortedHosts
            if let firstHost = sortedHosts.first {
                self.user?.currentHost = firstHost
            }
        }
    }
    
    
    func selectHost(_ host: Host) {
        self.user?.currentHost = host
        print("DEBUG: Selected host: \(host.name)")
    }
    
    
    func fetchUniversityId(for name: String,
                           completion: @escaping (String) -> Void) {
        let queryKey = QueryKey(collectionPath: "universities",
                                filters: ["shortName == \(name)"],
                                limit: 1)
        
        COLLECTION_UNIVERSITIES
            .whereField("shortName", isEqualTo: name)
            .limit(to: 1)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 86400) { snapshots, error in
                if let error = error {
                    print("DEBUG: Error fetching university. \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshots?.documents.first else { return }
                completion(document.documentID)
            }
    }
    
    
    func fetchUniversity(with id: String,
                         completion: @escaping (University) -> Void) {
        COLLECTION_UNIVERSITIES
            .document(id)
            .fetchWithCachePriority(freshnessDuration: 86400) { snapshot, error in
                if let error = error {
                    print("ERROR: Fetching university failed. ID: \(id), Error: \(error.localizedDescription)")
                    return
                }
                
                guard let university = try? snapshot?.data(as: University.self) else {
                    print("ERROR: Unable to decode university data. ID: \(id)")
                    return
                }
                print("SUCCESS: Fetched university data for ID: \(id)")
                completion(university)
            }
    }
    
    
    func fetchUniversities(with ids: [String], completion: @escaping ([University]) -> Void) {
        print("DEBUG: Fetching universities")
        guard !ids.isEmpty else {
            completion([])
            return
        }

        var allUniversities: [University] = []
        let dispatchGroup = DispatchGroup()

        for id in ids {
            dispatchGroup.enter()
            COLLECTION_UNIVERSITIES
                .document(id)
                .fetchWithCachePriority(freshnessDuration: 86400) { snapshot, error in
                    defer { dispatchGroup.leave() }

                    if let error = error {
                        print("DEBUG: Error fetching university: \(error.localizedDescription)")
                        return
                    }

                    guard let university = try? snapshot?.data(as: University.self) else { return }
                    // Manually setting the id of the university
                    var universityWithId = university
                    universityWithId.id = snapshot?.documentID
                    
                    allUniversities.append(universityWithId)
                }
        }

        dispatchGroup.notify(queue: .main) {
            print("DEBUG: Fetched \(allUniversities.count) universities")
            completion(allUniversities)
        }
    }
    
    
    func toggleFavoriteStatus(isFavorited: Bool,
                              event: Event,
                              completion: FirestoreCompletion) {
        guard let eventId = event.id else { return }
        guard let currentUserId = self.user?.id else { return }

        let eventFavoritesReference = COLLECTION_EVENTS.document(eventId).collection("event-favorites").document(currentUserId)
        let userFavoritesReference = COLLECTION_USERS.document(currentUserId).collection("user-favorites").document(eventId)

        let favoriteData = ["timestamp": Timestamp()] as [String: Any]
        let documentRefs = [eventFavoritesReference, userFavoritesReference]
        let documentRefsDataMap = Dictionary(uniqueKeysWithValues: documentRefs.map { ($0, favoriteData) })
        let batch = Firestore.firestore().batch()
        
        if isFavorited {
            batch
                .addBatchUpdate(documentRefsDataMap: documentRefsDataMap)
            
            NotificationsViewModel.preparePlannerNotificationBatch(for: event,
                                                                   type: .eventLiked,
                                                                   within: batch)
            batch.commit(completion: completion)
        } else {
            COLLECTION_NOTIFICATIONS
                .deleteNotificationsForPlanners(for: event,
                                                ofTypes: [.eventLiked],
                                                from: currentUserId,
                                                using: batch) {
                    batch.addBatchDelete(documentRefs: documentRefs)
                    batch.commit(completion: completion)
                }
        }
    }
    
    
    func fetchHosts(from event: Event, completion: @escaping ([Host]) -> Void) {
        var hosts = [Host]()
        let group = DispatchGroup()
        
        for hostId in event.hostIds {
            group.enter()
            fetchHost(from: hostId) { host in
                hosts.append(host)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(hosts)
        }
    }
    
    
    private func fetchHost(from id: String, completion: @escaping (Host) -> Void) {
        COLLECTION_HOSTS
            .document(id)
            .fetchWithCachePriority(freshnessDuration: 7200) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching host: \(error.localizedDescription)")
                    return
                }
                
                guard let host = try? snapshot?.data(as: Host.self) else { return }
                completion(host)
            }
    }
    
    
    func requestOrJoinGuestlist(for event: Event, completion: FirestoreCompletion) {
        guard let eventId = event.id,
              let user = self.user,
              let userId = user.id,
              user.isCurrentUser else { return }
        
        let guestStatus: GuestStatus = event.isInviteOnly ? .requested : .invited
        let guest = EventGuest(name: user.fullName,
                               universityId: user.universityId,
                               email: user.email,
                               profileImageUrl: user.profileImageUrl,
                               age: user.age,
                               gender: user.gender,
                               status: guestStatus,
                               timestamp: Timestamp())
        
        guard let encodedGuest = try? Firestore.Encoder().encode(guest) else { return }
        let batch = Firestore.firestore().batch()
        
        let guestlistReference = COLLECTION_EVENTS.document(eventId).collection("guestlist").document(userId)
        
        batch.setData(encodedGuest, forDocument: guestlistReference)
        
        if guestStatus == .invited {
            NotificationsViewModel.preparePlannerNotificationBatch(for: event,
                                                               type: .guestlistJoined,
                                                               within: batch)
        }
        
        batch.commit(completion: completion)
    }
    
    
    func cancelOrLeaveGuestlist(for event: Event, completion: FirestoreCompletion) {
        guard let eventId = event.id, let userId = self.user?.id else { return }
        
        let batch = Firestore.firestore().batch()
        
        // Reference to delete the user from the guestlist
        let guestReference = COLLECTION_EVENTS.document(eventId).collection("guestlist").document(userId)
        batch.deleteDocument(guestReference)
        
        // First, perform the query to find guest notifications to be deleted
        let queryKey = QueryKey(collectionPath: "notifications/\(userId)/user-notifications",
                                filters: ["eventId == \(eventId)", "type IN [\(NotificationType.guestlistAdded.rawValue)]"])
                                
        let notificationQuery = COLLECTION_NOTIFICATIONS
            .document(userId)
            .collection("user-notifications")
            .whereField("eventId", isEqualTo: eventId)
            .whereField("type", in: [NotificationType.guestlistAdded.rawValue])
        
        notificationQuery.fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 2000) { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                completion?(error)
                return
            }
            
            // Add each found notification document to the batch for deletion
            documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            // Assuming `deleteNotificationsForPlanners` adds planner notification deletions to the same batch
            COLLECTION_NOTIFICATIONS.deleteNotificationsForPlanners(for: event, ofTypes: [NotificationType.guestlistJoined], from: userId, using: batch) {
                // Now commit the batch after adding all deletions
                batch.commit { error in
                    completion?(error)
                }
            }
        }
    }
    
    
    func updateFollowStatus(didFollow: Bool,
                            hostUid: String,
                            completion: FirestoreCompletion) {
        guard let currentUid = self.user?.id else { return }
        
        let userFollowingRef = COLLECTION_FOLLOWING
            .document(currentUid)
            .collection("user-following")
            .document(hostUid)
        
        let hostFollowerRef = COLLECTION_FOLLOWERS
            .document(hostUid)
            .collection("host-followers")
            .document(currentUid)
        
        let documentRefs = [userFollowingRef, hostFollowerRef]
        let followData = ["timestamp": Timestamp()] as [String: Any]
        
        if didFollow {
            COLLECTION_FOLLOWING
                .batchUpdate(documentIDs: documentRefs.map { $0.documentID },
                             data: followData,
                             completion: completion)
        } else {
            COLLECTION_FOLLOWING
                .batchDelete(documentIDs: documentRefs.map { $0.documentID },
                             completion: completion)
        }
    }
    
    
//    static func leaveWaitlist(eventId: String, completion: FirestoreCompletion) {
//        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
//
//        COLLECTION_WAITLISTS.document(eventId).collection("users").document(currentUid)
//            .delete(completion: completion)
//    }
//

//    static func fetchQueueNumber(eventId: String, completion: @escaping (Int?) -> Void) {
//        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
//
//        COLLECTION_WAITLISTS.document(eventId).collection("users").order(by: "timestamp").getDocuments { snapshot, _ in
//            guard let documents = snapshot?.documents else { return }
//            let queueNumber = documents.firstIndex(where: { $0.documentID == currentUid }) ?? -1
//            completion(queueNumber)
//        }
//    }


    func checkIfHostIsFollowed(forId hostId: String,
                               completion: @escaping (Bool) -> Void) {
        guard let currentUid = self.user?.id else { return }

        COLLECTION_FOLLOWING
            .document(currentUid)
            .collection("user-following")
            .document(hostId)
            .fetchWithCachePriority(freshnessDuration: 1800) { snapshot, _ in
                guard let isFollowed = snapshot?.exists else { return }
                completion(isFollowed)
            }
    }
    
    
    func fetchBlockedUsers(completion: @escaping ([String]) -> Void) {
        guard let currentUserId = self.user?.id else { return }
        var blockedUsers = [String]()
        let queryKey = QueryKey(collectionPath: "relationships",
                                filters: ["initiatorUid == \(currentUserId)",
                                          "state == \(RelationshipState.blocked.rawValue)"])
        
        COLLECTION_RELATIONSHIPS
            .whereField("initiatorUid", isEqualTo: currentUserId)
            .whereField("state", isEqualTo: RelationshipState.blocked.rawValue)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 86400) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching blocked users: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                for document in snapshot?.documents ?? [] {
                    let relationship = try? document.data(as: Relationship.self)
                    if let recipientUid = relationship?.recipientUid {
                        blockedUsers.append(recipientUid)
                    }
                }
                
                completion(blockedUsers)
            }
    }
    
    
    func blockUser(_ blockedUser: User, completion: FirestoreCompletion) {
        guard let uid = blockedUser.id else { return}
        guard let currentUser = self.user, let currentUid = currentUser.id else { return }
        
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"
        
        let friendship = Relationship(initiatorUid: currentUid,
                                      recipientUid: uid,
                                      initiatorUsername: currentUser.username,
                                      recipientUsername: blockedUser.username,
                                      state: .blocked,
                                      updatedAt: Timestamp())
        
        guard let encodedRelationship = try? Firestore.Encoder().encode(friendship) else { return }
        
        COLLECTION_RELATIONSHIPS
            .document(path)
            .setData(encodedRelationship, merge: true, completion: completion)
    }


    func sendFriendRequest(username: String,
                           uid: String,
                           completion: FirestoreCompletion) {
        guard let currentUser = self.user else { return }
        guard let currentUid = currentUser.id else { return }
        
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"
        
        let friendship = Relationship(initiatorUid: currentUid,
                                      recipientUid: uid,
                                      initiatorUsername: currentUser.username,
                                      recipientUsername: username,
                                      state: .requestSent,
                                      updatedAt: Timestamp())
        
        guard let encodedRelationship = try? Firestore.Encoder().encode(friendship) else { return }
        
        COLLECTION_RELATIONSHIPS
            .document(path)
            .setData(encodedRelationship) { error in
                NotificationsViewModel.uploadNotification(toUid: uid,
                                                          type: .friendRequest)
                
                completion?(error)
            }
    }
    

    func cancelOrDeleteRelationship(uid: String, completion: FirestoreCompletion) {
        guard let currentUid = self.user?.id else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"
        
        let batch = Firestore.firestore().batch()
        let relationshipRef = COLLECTION_RELATIONSHIPS.document(path)
        batch.deleteDocument(relationshipRef)
        
        let dispatchGroup = DispatchGroup()
        
        // Enter the dispatch group before the first asynchronous operation
        dispatchGroup.enter()
        COLLECTION_NOTIFICATIONS.getNotificationDocumentReferences(forUserID: uid,
                                                                  ofTypes: [.friendAccepted, .friendRequest]) { documentReferences in
            if let documentReferences = documentReferences {
                Firestore.addDeleteOperations(to: batch, for: documentReferences)
            }
            // Leave the dispatch group after the operation is done
            dispatchGroup.leave()
        }
        
        // Enter the dispatch group before the second asynchronous operation
        dispatchGroup.enter()
        COLLECTION_NOTIFICATIONS.getNotificationDocumentReferences(forUserID: currentUid,
                                                                  ofTypes: [.friendAccepted, .friendRequest]) { documentReferences in
            if let documentReferences = documentReferences {
                Firestore.addDeleteOperations(to: batch, for: documentReferences)
            }
            // Leave the dispatch group after the operation is done
            dispatchGroup.leave()
        }
        
        // Commit the batch after both operations have completed
        dispatchGroup.notify(queue: .main) {
            batch.commit(completion: completion)
        }
    }


    func acceptFriendRequest(uid: String,
                             completion: FirestoreCompletion) {
        guard let currentUid = self.user?.id else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"
        
        let data: [String: Any] = ["state": RelationshipState.friends.rawValue,
                                   "timestamp": Timestamp()]
        
        let batch = Firestore.firestore().batch()
        
        // Reference to the relationship document
        let relationshipRef = COLLECTION_RELATIONSHIPS.document(path)
        batch.updateData(data, forDocument: relationshipRef)
        
        COLLECTION_NOTIFICATIONS
            .getNotificationDocumentReferences(forUserID: currentUid,
                                               ofTypes: [.friendRequest]) { documentReferences in
                if let documentReferences = documentReferences {
                    Firestore.addDeleteOperations(to: batch, for: documentReferences)
                }
                
                batch.commit { error in
                    if let error = error {
                        completion?(error)
                    } else {
                        // Send a "friend accepted" notification to the person who sent the request
                        NotificationsViewModel.uploadNotification(toUid: uid,
                                                                  type: .friendAccepted)
                        
                        HapticManager.playSuccess()
                        completion?(nil)
                    }
                }
            }
    }
    
    

    func getUserRelationship(uid: String,
                             completion: @escaping (RelationshipState) -> Void) {
        guard let currentUid = self.user?.id else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"

        COLLECTION_RELATIONSHIPS.document(path).getDocument { snapshot, _ in
            guard let hasRelationship = snapshot?.exists else { return }
            
            if !hasRelationship {
                completion(.notFriends)
            }
            
            guard let stateRawValue = snapshot?.get("state") as? Int else { return }
            guard let state = RelationshipState(rawValue: stateRawValue) else { return }
            
            switch state {
                case .friends:
                    completion(.friends)
                case .requestSent:
                    guard let initiatorUid = snapshot?.get("initiatorUid") as? String else { return }
                    completion(initiatorUid == currentUid ? .requestSent : .requestReceived)
                default:
                    // Should not execute but here in case
                    completion(state)
            }
        }
    }
}

// MARK: - CRUD Operations for host-associated functions; enforce permission!
extension UserService {
    func handlePlannerAction(forEvent event: Event,
                             actionType: NotificationType,
                             completion: FirestoreCompletion) {
        guard let currentUserId = self.user?.id,
              let eventId = event.id,
              let keyForCurrentUser = event.allPlannerIds?.first(where: { $0 == currentUserId}),
              let primaryPlannerId = event.primaryPlannerId,
              let hostId = keyForCurrentUser.hostId else {
            print("DEBUG: Failed to retrieve necessary data.")
            return
        }
        
        let batch = Firestore.firestore().batch()
        
        let eventRef = COLLECTION_EVENTS.document(eventId)
        var data: [String: Any] = [:]
        
        switch actionType {
        case .plannerAccepted:
            data["hostIds"] = FieldValue.arrayUnion([hostId])
            data["plannerHostStatusMap.\(keyForCurrentUser)"] = PlannerStatus.confirmed.rawValue
        case .plannerDeclined:
            data["plannerHostStatusMap.\(keyForCurrentUser)"] = PlannerStatus.declined.rawValue
        default:
            // Handle other notification types or do nothing
            break
        }
        
        // Add the update operation to the batch
        batch.updateData(data, forDocument: eventRef)
        
        // Assuming you want to delete notifications related to the action
        switch actionType {
        case .plannerAccepted,
                .plannerDeclined,
                .plannerRemoved:
            COLLECTION_NOTIFICATIONS
                .getNotificationDocumentReferences(forUserID: currentUserId,
                                                   ofTypes: [.plannerInvited],
                                                   from: primaryPlannerId) { documentReferences in
                    if let documentReferences = documentReferences {
                        Firestore.addDeleteOperations(to: batch, for: documentReferences)
                    }
                    
                    batch.commit { error in
                        if let error = error {
                            completion?(error)
                        } else {
                            NotificationsViewModel.preparePlannerNotificationBatch(for: event,
                                                                               type: actionType,
                                                                               within: batch)
                            completion?(nil)
                        }
                    }
                }
        default:
            // Handle other notification types or do nothing
            break
        }
    }
    
    
    func acceptMemberInvite(forHost host: Host,
                            fromUser userId: String,
                            completion: FirestoreCompletion) {
        print("DEBUG: Tapped button")
        
        guard let currentUser = self.user,
              let hostId = host.id,
              let memberId = currentUser.id else { return }
        
        print("DEBUG: not guards")
        
        EventManager.shared.fetchHostCurrentAndFutureEvents(for: hostId) { events in
            let eventIds = events.filter({ $0.isPrivate }).compactMap { $0.id }
            print("DEBUG: eventIds \(eventIds)")
            let batch = Firestore.firestore().batch()
            let data: [String: Any] = ["timestamp": Timestamp(), "status": MemberInviteStatus.joined.rawValue]
            let memberReference = COLLECTION_HOSTS.document(hostId).collection("member-list").document(memberId)
            batch.updateData(data, forDocument: memberReference)

            let updatedUserData: [String: Any] = ["hostIdToMemberTypeMap.\(hostId)": HostMemberType.member.rawValue]
            let currentUserReference = COLLECTION_USERS.document(memberId)
            batch.updateData(updatedUserData, forDocument: currentUserReference)

            COLLECTION_NOTIFICATIONS.getNotificationDocumentReferences(forUserID: memberId, ofTypes: [.memberInvited], from: userId) { documentReferences in
                if let documentReferences = documentReferences {
                    Firestore.addDeleteOperations(to: batch, for: documentReferences)
                }
                
                batch.commit { error in
                    if let error = error {
                        completion?(error)
                    } else {
                        NotificationsViewModel.uploadNotification(toUid: host.mainUserId, type: .memberJoined, host: host)
                        completion?(nil)
                    }
                }
            }
        }
    }

    func rejectMemberInvite(fromUser userId: String,
                            fromHost hostId: String,
                            memberId: String,
                            completion: FirestoreCompletion) {
        guard let currentUser = self.user else { return }
        guard memberId == currentUser.id else { return }
        
        let batch = Firestore.firestore().batch()
        let memberReferenceOnHost = COLLECTION_HOSTS.document(hostId).collection("member-list").document(memberId)
        
        batch.deleteDocument(memberReferenceOnHost)
        
        COLLECTION_NOTIFICATIONS
            .getNotificationDocumentReferences(forUserID: memberId,
                                               ofTypes: [.memberInvited],
                                               from: userId) { documentReferences in
                if let documentReferences = documentReferences {
                    Firestore.addDeleteOperations(to: batch, for: documentReferences)
                }
                
                batch.commit(completion: completion)
            }
    }
}
