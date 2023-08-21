//
//  Gender.swift
//  mixer
//
//  Created by Peyton Lyons on 8/9/23.
//

import SwiftUI

enum Gender: Int, Codable, CustomStringConvertible, CaseIterable {
    case woman
    case man
    case other
    case preferNotToSay

    var description: String {
        switch self {
            case .woman: return "Woman"
            case .man: return "Man"
            case .other: return "Other"
            case .preferNotToSay: return "Prefer not to say"
        }
    }
    
    var icon: String {
        switch self {
            case .woman: return "woman"
            case .man: return "man"
            case .other: return "unisex"
            case .preferNotToSay: return ""
        }
    }
}
