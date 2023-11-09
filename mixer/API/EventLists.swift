//
//  EventLists.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import Firebase
import SwiftUI

enum GuestStatus: Int, Codable, CustomStringConvertible, CaseIterable {
    case invited
    case checkedIn
    case requested
    
    var description: String {
        switch self {
            case .invited: return "Invites"
            case .checkedIn: return "Check-ins"
            case .requested: return "Requests"
        }
    }
    
    var pickerTitle: String {
        switch self {
            case .invited: return "Send Invite"
            case .checkedIn: return "Mark as Checked-in"
            default: return ""
        }
    }
    
    var icon: String {
        switch self {
            case .invited: "list.clipboard"
            case .checkedIn: "person.badge.minus"
            case .requested: "hourglass"
        }
    }
    
    var guestlistButtonTitle: String {
        switch self {
            case .invited: "Check in"
            case .checkedIn: "Remove"
            case .requested: "Accept"
        }
    }
}

struct EventLists {
    static func loadUsers(eventId: String, completion: @escaping ([EventGuest]) -> Void) {
        var users = [EventGuest]()
        
        COLLECTION_EVENTS.document(eventId).collection("guestlist").getDocuments() { snapshot, error in
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
