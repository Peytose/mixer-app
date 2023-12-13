//
//  University.swift
//  mixer
//
//  Created by Peyton Lyons on 7/28/23.
//

import FirebaseFirestoreSwift
import Firebase
import SwiftUI

struct University: Hashable, Identifiable, Codable {
    var id: String?
    let domain: String
    var name: String
    var shortName: String?
    var url: String?
    
    var icon: String? {
        return self.id != "com" ? "graduationcap.fill" : "exclamationmark.circle.fill"
    }
    
    enum UniversityCodingKeys: String, CodingKey {
        case objectId = "objectID"
        case domain
        case name
        case shortName
        case url
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UniversityCodingKeys.self)
        
        // Decode objectId
        id = try? container.decode(String.self, forKey: .objectId)
        
        // Decode other properties
        domain = try container.decode(String.self, forKey: .domain)
        name = try container.decode(String.self, forKey: .name)
        shortName = try? container.decode(String.self, forKey: .shortName)
        url = try? container.decode(String.self, forKey: .url)
    }
    
    init(id: String? = nil,
         domain: String,
         name: String,
         shortName: String? = nil,
         url: String) {
        self.id = id
        self.domain = domain
        self.name = name
        self.shortName = shortName
        self.url = url
    }
}
