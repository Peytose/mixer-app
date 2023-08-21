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
    var profileImageUrl: String?
    var age: Int?
    let gender: Gender
    var status: GuestStatus?
    var invitedBy: String?
    var checkedInBy: String?
    var timestamp: Timestamp?
    
    init(from user: User,
         invitedBy: String? = nil,
         checkedInBy: String? = nil) {
        self.name            = user.name
        self.university      = (user.university?.shortName ?? user.university?.name) ?? "n/a"
        self.profileImageUrl = user.profileImageUrl
        self.age             = Calendar.current.dateComponents([.year], from: user.birthday.dateValue(), to: Date()).year ?? 18
        self.gender          = user.gender
        self.status          = .invited
        self.invitedBy       = invitedBy
        self.checkedInBy     = checkedInBy
        self.timestamp       = Timestamp()
    }
    
    init(name: String,
         university: String,
         age: Int? = nil,
         gender: Gender,
         status: GuestStatus? = .invited,
         invitedBy: String? = nil,
         timestamp: Timestamp? = Timestamp()) {
        self.name       = name
        self.university = university
        self.age        = age
        self.gender     = gender
        self.status     = status
        self.invitedBy  = invitedBy
        self.timestamp  = timestamp
    }
}
