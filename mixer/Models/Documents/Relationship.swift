//
//  Relationship.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import FirebaseFirestoreSwift
import Firebase

enum RelationshipCodingKeys: String, CodingKey {
    case objectId = "objectID"
    case initiatorUid
    case recipientUid
    case initiatorUsername
    case recipientUsername
    case blockedByUid
    case state
    case updatedAt
}

struct Relationship: Codable {
    var objectId: String?
    let initiatorUid: String
    let recipientUid: String
    let initiatorUsername: String
    let recipientUsername: String
    var blockedByUid: String?
    var state: RelationshipState
    var updatedAt: Timestamp
    
    
    init(initiatorUid: String,
         recipientUid: String,
         initiatorUsername: String,
         recipientUsername: String,
         blockedByUid: String? = nil,
         state: RelationshipState,
         updatedAt: Timestamp) {
        self.initiatorUid = initiatorUid
        self.recipientUid = recipientUid
        self.initiatorUsername = initiatorUsername
        self.recipientUsername = recipientUsername
        self.blockedByUid = blockedByUid
        self.state = state
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RelationshipCodingKeys.self)
        objectId = try? container.decode(String.self, forKey: .objectId)
        initiatorUid = try container.decode(String.self, forKey: .initiatorUid)
        recipientUid = try container.decode(String.self, forKey: .recipientUid)
        initiatorUsername = try container.decode(String.self, forKey: .initiatorUsername)
        recipientUsername = try container.decode(String.self, forKey: .recipientUsername)
        blockedByUid = try? container.decode(String.self, forKey: .blockedByUid)
        state = try container.decode(RelationshipState.self, forKey: .state)
        
        // Custom decoding for updatedAt
        if let unixTimestampMillis = try? container.decode(Double.self, forKey: .updatedAt) {
            let seconds = Int(unixTimestampMillis / 1000)
            let nanoseconds = Int((unixTimestampMillis.truncatingRemainder(dividingBy: 1000)) * 1_000_000) // Convert remainder milliseconds to nanoseconds 
            updatedAt = Timestamp(seconds: Int64(seconds), nanoseconds: Int32(nanoseconds))
        } else if let timestamp = try? container.decode(Timestamp.self, forKey: .updatedAt) {
            updatedAt = timestamp
        } else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Invalid updatedAt value")
        }
    }
}

