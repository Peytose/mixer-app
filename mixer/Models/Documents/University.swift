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
    @DocumentID var id: String?
    let domain: String
    var name: String
    var shortName: String?
    let url: String
    
    var icon: String? {
        return self.id != "com" ? "graduationcap.fill" : "exclamationmark.circle.fill"
    }
}
