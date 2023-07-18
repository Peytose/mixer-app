//
//  EventGuest.swift
//  mixer
//
//  Created by Peyton Lyons on 4/18/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

struct EventGuest: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    let university: String
    var profileImageUrl: String?
    var age: Int?
    var gender: String?
    var status: GuestStatus?
    var invitedBy: String?
    var checkedInBy: String?
    var timestamp: Timestamp?
    
    init(from user: CachedUser, invitedBy: String? = nil, checkedInBy: String? = nil) {
        self.name            = user.name
        self.university      = user.universityData["name"] ?? ""
        self.profileImageUrl = user.profileImageUrl
        
        let age = Calendar.current.dateComponents([.year], from: user.birthday.dateValue(), to: Date()).year
        self.age         = age ?? 18 // defaulting to 18 if age isn't available
        
        self.status          = .invited
        self.invitedBy       = invitedBy
        self.checkedInBy     = checkedInBy
        self.timestamp       = Timestamp()
    }
    
    init(name: String, university: String, age: Int?, gender: String?, status: GuestStatus?, invitedBy: String?, timestamp: Timestamp?) {
        self.name       = name
        self.university = university
        self.age        = age
        self.gender     = gender
        self.status     = status
        self.invitedBy  = invitedBy
        self.timestamp  = timestamp
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            "name": name,
            "university": university,
            "age": age ?? 1,
            "status": status?.rawValue ?? GuestStatus.invited.rawValue,
            "timestamp": timestamp ?? Timestamp(),
        ]
        
        if let profileImageUrl = profileImageUrl {
            dictionary["profileImageUrl"] = profileImageUrl
        }
        
        if let gender = gender {
            dictionary["gender"] = gender
        }
        
        if let invitedBy = invitedBy {
            dictionary["invitedBy"] = invitedBy
        }
        
        if let checkedInBy = checkedInBy {
            dictionary["checkedInBy"] = checkedInBy
        }

        return dictionary
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
