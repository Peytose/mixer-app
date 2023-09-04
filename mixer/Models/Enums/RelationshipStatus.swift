//
//  DatingStatus.swift
//  mixer
//
//  Created by Peyton Lyons on 8/9/23.
//

import SwiftUI

enum DatingStatus: Int, Codable, CustomStringConvertible, CaseIterable {    
    case single
    case taken
    case complicated
    case preferNotToSay

    var description: String {
        switch self {
            case .single: return "Single"
            case .taken: return "Taken"
            case .complicated: return "Complicated"
            case .preferNotToSay: return "Prefer not to say"
        }
    }

    var icon: String {
        switch self {
            case .single: return "person"
            case .taken: return "heart.fill"
            case .complicated: return "questionmark.diamond.fill"
            case .preferNotToSay: return "ellipsis.circle.fill"
        }
    }
}
