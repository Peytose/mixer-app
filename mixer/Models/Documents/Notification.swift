//
//  Notification.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import FirebaseFirestoreSwift
import FirebaseFirestore
import Firebase

struct Notification: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var hostId: String?
    var eventId: String?
    let uid: String
    var headline: String
    let timestamp: Timestamp
    var expireAt: Timestamp
    var imageUrl: String
    var type: NotificationType
    
    var isFollowed: Bool? = false
    var isFriends: Bool? = false
    
    var count: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uid)
        hasher.combine(headline)
        // You can add other properties if needed.
    }
}
