//
//  Host.swift
//  mixer
//
//  Created by Peyton Lyons on 1/12/23.
//

import FirebaseFirestoreSwift
import FirebaseFirestore

struct Host: Hashable, Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let ownerUuid: String
    let username: String
    let hostImageUrl: String
    let university: String
    let typesOfEventsHeld: [EventType]
    
    var instagramHandle: String?
    var website: String?
    var address: String?
    var bio: String?
}
