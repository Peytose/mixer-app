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
                
                if !(user.hostIdToAccountTypeMap?.isEmpty ?? true) {
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
        guard let hostIds = user?.hostIdToAccountTypeMap?.keys else { return }
        
        HostManager.shared.fetchHosts(with: Array(hostIds)) { hosts in
            self.user?.associatedHosts = hosts
        }
    }
    
    
    func fetchUniversity(with id: String,
                         completion: @escaping (University) -> Void) {
        COLLECTION_UNIVERSITIES
            .document(id)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching university. \(error.localizedDescription)")
                    return
                }
                
                guard let university = try? snapshot?.data(as: University.self) else { return }
                print("DEBUG: University associated with user: \(university)")
                completion(university)
            }
    }
    
    
    func fetchUniversities(with ids: [String] = [],
                           completion: @escaping ([University]) -> Void) {
        let chunks = ids.chunked(into: 10)
        
        for chunk in chunks {
            COLLECTION_UNIVERSITIES
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("DEBUG: Error fetching university. \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    let universities = documents.compactMap({ try? $0.data(as: University.self) })
                    completion(universities)
                }
        }
    }
    
    
    func toggleFavoriteStatusStatus(isFavorited: Bool,
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
                .batchUpdate(documentRefsDataMap: documentRefsDataMap) { error in
                    NotificationsViewModel.sendNotificationsToPlanners(for: event, with: .eventLiked)
                    
                    completion?(error)
                }
        } else {
            batch
                .batchDelete(documentRefs: documentRefs) { error in
                    COLLECTION_NOTIFICATIONS
                        .deleteNotificationsForPlanners(for: event,
                                                        ofTypes: [.eventLiked],
                                                        from: currentUserId,
                                                        completion: completion)
                    
                    completion?(error)
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
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching host: \(error.localizedDescription)")
                    return
                }
                
                guard let host = try? snapshot?.data(as: Host.self) else { return }
                completion(host)
            }
    }
    
    
    func requestOrJoinGuestlist(for event: Event, completion: FirestoreCompletion) {
        guard !event.isInviteOnly,
              let eventId = event.id,
              let user = self.user,
              let userId = user.id,
              userId == Auth.auth().currentUser?.uid else { return }
        
        let guestStatus: GuestStatus = event.isManualApprovalEnabled ? .requested : .invited
        let guest = EventGuest(name: user.name,
                               universityId: user.universityId,
                               email: user.email,
                               profileImageUrl: user.profileImageUrl,
                               age: user.age,
                               gender: user.gender,
                               status: guestStatus,
                               timestamp: Timestamp())
        
        guard let encodedGuest = try? Firestore.Encoder().encode(guest) else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(userId)
            .setData(encodedGuest) { error in
                if guestStatus == .invited {
                    NotificationsViewModel.sendNotificationsToPlanners(for: event,
                                                                       with: .guestlistJoined)
                }
                
                completion?(error)
            }
    }
    
    
    func cancelOrLeaveGuestlist(for event: Event, completion: FirestoreCompletion) {
        guard let eventId = event.id else { return }
        guard let userId = self.user?.id else { return }
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .document(userId)
            .delete { error in
                if let error = error {
                    print("DEBUG: Error leaving guestlist: \(error.localizedDescription)")
                    return
                }
                
                COLLECTION_NOTIFICATIONS
                    .deleteNotificationsForPlanners(for: event,
                                                    ofTypes: [NotificationType.guestlistJoined],
                                                    from: userId,
                                                    completion: completion)
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

        COLLECTION_FOLLOWING.document(currentUid).collection("user-following")
            .document(hostId).getDocument { snapshot, _ in
                guard let isFollowed = snapshot?.exists else { return }
                completion(isFollowed)
            }
    }
    
    
    func fetchBlockedUsers(completion: @escaping ([String]) -> Void) {
        guard let currentUserId = self.user?.id else { return }
        var blockedUsers = [String]()
        
        // Assuming you have a Firebase collection for relationships.
        COLLECTION_RELATIONSHIPS
            .whereField("initiatorUid", isEqualTo: currentUserId)
            .whereField("state", isEqualTo: RelationshipState.blocked.rawValue)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching blocked users: \(error.localizedDescription)")
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

        COLLECTION_RELATIONSHIPS
            .document(path)
            .delete { error in
                if let error = error {
                    completion?(error)
                    return
                }
                
                COLLECTION_NOTIFICATIONS
                    .deleteNotifications(forUserID: uid,
                                         ofTypes: [.friendAccepted,
                                                   .friendRequest],
                                         from: currentUid,
                                         completion: completion)
                
                COLLECTION_NOTIFICATIONS
                    .deleteNotifications(forUserID: currentUid,
                                         ofTypes: [.friendAccepted,
                                                   .friendRequest],
                                         from: uid,
                                         completion: completion)
            }
    }


    func acceptFriendRequest(uid: String,
                             completion: FirestoreCompletion) {
        guard let currentUid = self.user?.id else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"
        
        let data: [String: Any] = ["state": RelationshipState.friends.rawValue,
                                   "timestamp": Timestamp()]
        
        // Update friendship state
        COLLECTION_RELATIONSHIPS
            .document(path)
            .updateData(data) { error in
                // Send a "friend accepted" notification to the person who sent the request
                NotificationsViewModel.uploadNotification(toUid: uid,
                                                          type: .friendAccepted)
                
                completion?(error)
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
              let keyForCurrentUser = event.plannerHostStatusMap.keys.first(where: { $0.plannerId == currentUserId }),
              let primaryPlannerKey = event.primaryPlannerKey?.plannerId,
              let hostId = keyForCurrentUser.hostId else {
            print("DEBUG: Failed to retrieve necessary data.")
            return
        }
        
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
        
        COLLECTION_EVENTS
            .document(eventId)
            .updateData(data) { error in
                if let error = error {
                    completion?(error)
                    return
                }
                
                NotificationsViewModel.sendNotificationsToPlanners(for: event,
                                                                   with: actionType)
                
                // Assuming you want to delete notifications related to the action
                switch actionType {
                case .plannerAccepted,
                        .plannerDeclined,
                        .plannerRemoved:
                    COLLECTION_NOTIFICATIONS
                        .deleteNotifications(forUserID: currentUserId,
                                             ofTypes: [.plannerInvited],
                                             from: primaryPlannerKey,
                                             completion: completion)
                default:
                    // Handle other notification types or do nothing
                    break
                }
            }
    }
    
    
    func acceptMemberInvite(forHost host: Host,
                            fromUser userId: String,
                            completion: FirestoreCompletion) {
        guard let currentUser = self.user,
              let hostId = host.id,
              let memberId = currentUser.id else { return }
        
        let data: [String: Any] = ["timestamp": Timestamp(),
                                   "status": MemberInviteStatus.joined.rawValue]
        
        COLLECTION_HOSTS
            .document(hostId)
            .collection("member-list")
            .document(memberId)
            .updateData(data) { error in
                if let error = error {
                    print("DEBUG: Error updating member doc : \(error.localizedDescription)")
                    completion?(error)
                    return
                }
                
                guard let currentUserId = currentUser.id else { return }
                let updatedUserData: [String: Any] = ["hostIdToAccountTypeMap.\(hostId)": HostAccountType.member.rawValue]
                
                COLLECTION_USERS
                    .document(currentUserId)
                    .updateData(updatedUserData) { error in
                        if let error = error {
                            print("DEBUG: Error updating member doc : \(error.localizedDescription)")
                            completion?(error)
                            return
                        }
                        
                        NotificationsViewModel.uploadNotification(toUid: host.mainUserId,
                                                                  type: .memberJoined,
                                                                  host: host)
                        
                        COLLECTION_NOTIFICATIONS
                            .deleteNotifications(forUserID: memberId,
                                                 ofTypes: [.memberInvited],
                                                 from: userId,
                                                 completion: completion)
                    }
            }
    }
    
    func rejectMemberInvite(fromUser userId: String,
                            fromHost hostId: String,
                            memberId: String,
                            completion: FirestoreCompletion) {
        guard let currentUser = self.user else { return }
        guard memberId == currentUser.id else { return }
        
        COLLECTION_HOSTS
            .document(hostId)
            .collection("member-list")
            .document(memberId)
            .delete { error in
                if let error = error {
                    completion?(error)
                    return
                }
                
                COLLECTION_NOTIFICATIONS
                    .deleteNotifications(forUserID: memberId,
                                         ofTypes: [.memberInvited],
                                         from: userId,
                                         completion: completion)
            }
    }
    
    
    func removeMember(fromHost hostId: String,
                      member: User,
                      completion: FirestoreCompletion) {
        guard let memberId = member.id else { return }
        guard let currentUser = self.user, let currentUserId = currentUser.id else { return }
        guard currentUser.hostIdToAccountTypeMap?.keys.contains(where: { $0 == hostId }) ?? false else { return }
        
        COLLECTION_HOSTS
            .document(hostId)
            .collection("member-list")
            .document(memberId)
            .delete { error in
                if let error = error {
                    completion?(error)
                    return
                }
                
                let updatedUserData: [String: Any] = ["hostIdToAccountTypeMap.\(hostId)": FieldValue.delete()]
                
                COLLECTION_USERS
                    .document(memberId)
                    .updateData(updatedUserData) { error in
                        if let error = error {
                            completion?(error)
                            return
                        }
                        
                        COLLECTION_NOTIFICATIONS
                            .deleteNotifications(forUserID: currentUserId,
                                                 ofTypes: [.memberJoined],
                                                 from: memberId,
                                                 completion: completion)
                    }
            }
    }
}
