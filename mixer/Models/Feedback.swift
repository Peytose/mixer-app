//
//  Feedback.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import Firebase

struct Feedback: Identifiable, Decodable {
    @DocumentID var id: String?
    let eventUuid: String
    let hostUuid: String
    let rating: Int
    let comment: String
    let eventType: EventType
    let isAnonymous: Bool
    let createdAt: Timestamp
    
    var userId: String?
    var user: User?
    var musicRating: Int?
    var crowdRating: Int?
    var venueRating: Int?
    var drinksRating: Int?
    var recommendsEvent: Bool?
}
