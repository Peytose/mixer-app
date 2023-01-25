//
//  Host.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift

struct Host: Identifiable, Decodable {
    @DocumentID var id: String?
    let ownerUuid: String
    let username: String
    let hostImageUrl: String
    let university: String
    let typesOfEventsHeld: [EventType]
    
    var instagramHandle: String?
    var rating: Float?
    var address: String?
    var bio: String?
    var isFollowed: Bool? = false
    var isCurrentHost: Bool?
}
