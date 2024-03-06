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
        case .invited: return "Just Invite"
        case .checkedIn: return "Invite & Check-in"
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
    
    var guestlistSectionTitle: String {
        switch self {
        case .invited: return "Invited"
        case .checkedIn: return "Checked-in"
        case .requested: return "Requested"
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

enum GuestEntryType: Int, Codable, CaseIterable {
    case username
    case manual
    
    var pickerTitle: String {
        switch self {
        case .username: return "Username"
        case .manual: return "Manual"
        }
    }
}

struct EventLists {
    static func loadUsers(eventId: String, completion: @escaping ([EventGuest]) -> Void) {
        var users = [EventGuest]()
        
        let queryKey = QueryKey(collectionPath: "events/\(eventId)/guestlist")
        
        COLLECTION_EVENTS
            .document(eventId)
            .collection("guestlist")
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 1800) { snapshot, error in
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
