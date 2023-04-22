//
//  EventGuest.swift
//  mixer
//
//  Created by Peyton Lyons on 4/18/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

struct EventGuest: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let university: String
    
    var age: Int?
    var gender: String?
    var status: GuestStatus?
    var invitedBy: String?
    var timestamp: Timestamp?
}
