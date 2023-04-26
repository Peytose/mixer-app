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
    var gender: String?
    var status: GuestStatus?
    var invitedBy: String?
    var timestamp: Timestamp?
    
    init(from user: CachedUser) {
        self.id              = user.id
        self.name            = user.name
        self.profileImageUrl = user.profileImageUrl
        
        if let age = Calendar.current.dateComponents([.year], from: user.birthday.dateValue(), to: Date()).year {
            self.age         = age
        }
        
        self.university      = user.universityData["name"] ?? ""
    }
    
    init(name: String, university: String, age: Int?, gender: String?, status: GuestStatus?, invitedBy: String?, timestamp: Timestamp?) {
        self.name = name
        self.university = university
        self.age = age
        self.gender = gender
        self.status = status
        self.invitedBy = invitedBy
        self.timestamp = timestamp
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id as String? ?? "",
            "name": name as String,
            "university": university as String,
            "profileImageUrl": profileImageUrl as String? ?? "",
            "age": age as Int? ?? 1,
            "gender": gender as String? ?? "",
            "status": status as GuestStatus? ?? "",
            "invitedBy": invitedBy as String? ?? "",
            "timestamp": timestamp as Timestamp? ?? Timestamp(),
        ]
    }
}
