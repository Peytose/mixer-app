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
    var name: String
    var universityId: String
    var email: String?
    var username: String?
    var profileImageUrl: String?
    var age: Int?
    var gender: Gender
    var status: GuestStatus
    var invitedBy: String?
    var checkedInBy: String?
    var timestamp: Timestamp?
    
    var university: University?
    
    init(name: String,
         universityId: String,
         email: String? = nil,
         username: String? = nil,
         profileImageUrl: String? = nil,
         age: Int? = nil,
         gender: Gender,
         status: GuestStatus = .invited,
         invitedBy: String? = nil,
         checkedInBy: String? = nil,
         timestamp: Timestamp? = Timestamp(),
         university: University? = nil) {
        self.name            = name
        self.profileImageUrl = profileImageUrl
        self.email           = email
        self.username        = username
        self.universityId    = universityId
        self.age             = age
        self.gender          = gender
        self.status          = status
        self.invitedBy       = invitedBy
        self.timestamp       = timestamp
        self.university      = university
    }
}
