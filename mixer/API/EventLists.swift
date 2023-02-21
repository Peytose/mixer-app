//
//  EventLists.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import Firebase
import SwiftUI

enum ListType {
    case invite
    case attend
    
    var fieldValue: String {
        switch self {
            case .invite: return "isInvited"
            case .attend: return "isCheckedIn"
        }
    }
}

struct EventLists {
    static func loadUsers(eventUid: String, type: ListType) -> [User] {
        var users = [User]()
        
        COLLECTION_EVENTS.document(eventUid).collection("attendance-list")
            .whereField("status", isEqualTo: type.fieldValue).getDocuments() { snapshot, _ in
                guard let snapshot = snapshot else { return }
                users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
            }
        
        return users
    }
}
