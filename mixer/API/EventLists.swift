//
//  EventLists.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import Firebase
import SwiftUI

enum GuestStatus: String, Codable, CaseIterable {
    case invited   = "isInvited"
    case checkedIn = "isCheckedIn"
    
    var description: String {
        switch self {
            case .invited: return "Invite"
            case .checkedIn: return "Check-in"
        }
    }
}

struct EventLists {
    static func loadUsers(eventUid: String, completion: @escaping ([EventGuest]) -> Void) {
        var users = [EventGuest]()
        
        COLLECTION_EVENTS.document(eventUid).collection("guestlist").getDocuments() { snapshot, error in
            if let error = error {
                print("DEBUG: Error getting users from event list: \(error.localizedDescription)")
                completion(users)
                return
            }
            
            guard let snapshot = snapshot else { completion(users); return }
            users = snapshot.documents.compactMap({ try? $0.data(as: EventGuest.self) })
            print("DEBUG: Users from event list: \(users)")
            completion(users)
        }
    }
}
