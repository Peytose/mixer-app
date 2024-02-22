//
//  HostUserLink.swift
//  mixer
//
//  Created by Peyton Lyons on 8/22/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

enum MemberInviteStatus: Int, CustomStringConvertible, CaseIterable, Codable {
    case invited
    case joined
    
    var description: String {
        switch self {
            case .invited: return "Invited"
            case .joined: return "Joined"
        }
    }
}

struct HostUserLink: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var timestamp: Timestamp?
    var status: MemberInviteStatus
    var uid: String
    
    
    static func == (lhs: HostUserLink, rhs: HostUserLink) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}
