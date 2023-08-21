//
//  SearchItem.swift
//  mixer
//
//  Created by Peyton Lyons on 8/20/23.
//

import Foundation

enum SearchItemCodingKeys: String, CodingKey {
    case objectId = "objectID"
    case title
    case subtitle
    case imageUrl
    case displayName
    case username
    case description
    case profileImageUrl
    case eventImageUrl
    case hostImageUrl
    case name
}

struct SearchItem: Codable, Identifiable, Hashable {
    var objectId: String?
    let title: String
    let subtitle: String
    let imageUrl: String

    var id: String? { return objectId }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SearchItemCodingKeys.self)

        // Decode objectId (common across all types)
        objectId = try container.decode(String.self, forKey: .objectId)

        // Decode title, subtitle, imageUrl based on different keys for events, hosts, users
        if let value = try? container.decode(String.self, forKey: .title) {
            title = value
        } else if let value = try? container.decode(String.self, forKey: .displayName) {
            title = value
        } else if let value = try? container.decode(String.self, forKey: .name) {
            title = value
        } else {
            throw DecodingError.keyNotFound(CodingKeys.title, .init(codingPath: container.codingPath, debugDescription: "Title key not found"))
        }

        if let value = try? container.decode(String.self, forKey: .subtitle) {
            subtitle = value
        } else if let value = try? container.decode(String.self, forKey: .username) {
            subtitle = value
        } else if let value = try? container.decode(String.self, forKey: .description) {
            subtitle = value
        } else {
            throw DecodingError.keyNotFound(CodingKeys.subtitle, .init(codingPath: container.codingPath, debugDescription: "Subtitle key not found"))
        }

        if let value = try? container.decode(String.self, forKey: .imageUrl) {
            imageUrl = value
        } else if let value = try? container.decode(String.self, forKey: .profileImageUrl) {
            imageUrl = value
        } else if let value = try? container.decode(String.self, forKey: .eventImageUrl) {
            imageUrl = value
        } else if let value = try? container.decode(String.self, forKey: .hostImageUrl) {
            imageUrl = value
        } else {
            throw DecodingError.keyNotFound(CodingKeys.imageUrl, .init(codingPath: container.codingPath, debugDescription: "Image URL key not found"))
        }
    }
    
    init(objectId: String, title: String, subtitle: String, imageUrl: String) {
        self.objectId = objectId
        self.title    = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
    }
}
