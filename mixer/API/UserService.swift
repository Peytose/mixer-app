//
//  UserService.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import Firebase

typealias FirestoreCompletion = ((Error?) -> Void)?

class UserService: ObservableObject {
    static let shared = UserService()
    @Published var user: User?
    
    init() {
        fetchUser()
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            print("DEBUG: Did fetch user from firestore.")
            guard let user = try? snapshot?.data(as: User.self) else { return }
            self.user = user
            
            if user.accountType == .host || user.accountType == .member {
                self.fetchAssociatedHosts()
            }
        }
    }

    
    private func fetchAssociatedHosts() {
        guard let userId = user?.id else { return }
        
        COLLECTION_HOSTS
            .whereField("memberIds", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching host. \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let hosts = documents.compactMap({ try? $0.data(as: Host.self) })
                print("DEBUG: Hosts associated with user: \(hosts)")
                self.user?.associatedHosts = hosts
            }
    }
    
    
    func updateFavoriteStatus(didFavorite: Bool, eventUid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }

        let eventFavoritesRef = COLLECTION_EVENTS.document(eventUid).collection("event-favorites").document(currentUid)
        let userFavoritesRef = COLLECTION_USERS.document(currentUid).collection("user-favorites").document(eventUid)

        let batch = Firestore.firestore().batch()

        if didFavorite {
            let data = ["timestamp": Timestamp()] as [String: Any]

            batch.setData(data, forDocument: eventFavoritesRef)
            batch.setData(data, forDocument: userFavoritesRef)
        } else {
            batch.deleteDocument(eventFavoritesRef)
            batch.deleteDocument(userFavoritesRef)
        }

        batch.commit(completion: completion)
    }
    
    
    func updateFollowStatus(didFollow: Bool, hostUid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }

        let userFollowingRef = COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(hostUid)
        let hostFollowerRef = COLLECTION_FOLLOWERS.document(hostUid).collection("host-followers").document(currentUid)

        let batch = Firestore.firestore().batch()

        if didFollow {
            let data = ["timestamp": Timestamp()] as [String: Any]

            batch.setData(data, forDocument: userFollowingRef)
            batch.setData(data, forDocument: hostFollowerRef)
        } else {
            batch.deleteDocument(userFollowingRef)
            batch.deleteDocument(hostFollowerRef)
        }

        batch.commit(completion: completion)
    }
    
    
//    static func joinGuestlist(eventUid: String, user: User, completion: FirestoreCompletion) {
//        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
//
//        let guest = EventGuest(from: user).toDictionary()
//
//        COLLECTION_EVENTS.document(eventUid).collection("guestlist").document(currentUid)
//            .setData(guest, completion: completion)
//    }
//
//
//    static func leaveWaitlist(eventUid: String, completion: FirestoreCompletion) {
//        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
//
//        COLLECTION_WAITLISTS.document(eventUid).collection("users").document(currentUid)
//            .delete(completion: completion)
//    }
//

//    static func fetchQueueNumber(eventUid: String, completion: @escaping (Int?) -> Void) {
//        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
//
//        COLLECTION_WAITLISTS.document(eventUid).collection("users").order(by: "timestamp").getDocuments { snapshot, _ in
//            guard let documents = snapshot?.documents else { return }
//            let queueNumber = documents.firstIndex(where: { $0.documentID == currentUid }) ?? -1
//            completion(queueNumber)
//        }
//    }


    func checkIfHostIsFollowed(forId hostId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }

        COLLECTION_FOLLOWING.document(currentUid).collection("user-following")
            .document(hostId).getDocument { snapshot, _ in
                guard let isFollowed = snapshot?.exists else { return }
                completion(isFollowed)
            }
    }


    func sendFriendRequest(username: String, uid: String, completion: FirestoreCompletion) {
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        guard let currentUid = currentUser.id else { return }
        
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"
        
        let friendship = Friendship(fromUserUid: currentUid,
                                    toUserUid: uid,
                                    fromUsername: currentUser.username,
                                    toUsername: username,
                                    state: .requestSent,
                                    timestamp: Timestamp())

        guard let encodedFriendship = try? Firestore.Encoder().encode(friendship) else { return }
        
        COLLECTION_FRIENDSHIPS.document(path).setData(encodedFriendship, completion: completion)
    }


    func cancelRequestOrRemoveFriend(uid: String, completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"

        COLLECTION_FRIENDSHIPS.document(path).delete(completion: completion)
    }


    func acceptFriendRequest(uid: String, notificationId: String? = "", completion: FirestoreCompletion) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"

        let data: [String: Any] = ["state": FriendshipState.friends,
                                   "timestamp": Timestamp()]
        
        COLLECTION_FRIENDSHIPS.document(path).updateData(data, completion: completion)
    }


    func getUserRelationship(uid: String, completion: @escaping (FriendshipState) -> Void) {
        guard let currentUid = AuthViewModel.shared.userSession?.uid else { return }
        let path = "\(min(currentUid, uid))-\(max(currentUid, uid))"

        COLLECTION_FRIENDSHIPS.document(path).getDocument { snapshot, _ in
            guard let hasFriendship = snapshot?.exists else { return }
            
            if !hasFriendship {
                completion(.notFriends)
            }
            
            guard let stateRawValue = snapshot?.get("state") as? Int else { return }
            guard let state = FriendshipState(rawValue: stateRawValue) else { return }
            
            switch state {
                case .friends:
                    completion(.friends)
                case .requestSent:
                    guard let fromUserUid = snapshot?.get("fromUserUid") as? String else { return }
                    completion(fromUserUid == currentUid ? .requestSent : .requestReceived)
                default:
                    // Should not execute but here in case
                    completion(state)
            }
        }
    }
}
