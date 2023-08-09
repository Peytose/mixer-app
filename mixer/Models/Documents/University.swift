//
//  University.swift
//  mixer
//
//  Created by Peyton Lyons on 7/28/23.
//

import FirebaseFirestoreSwift
import Firebase

struct University: Hashable, Identifiable, Codable {
    let id = UUID().uuidString
    let domain: String
    var name: String
    var shortName: String?
    let url: String
}
