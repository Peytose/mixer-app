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

    var stringVal: String {
        switch self {
            case .woman: return "Woman"
            case .man: return "Man"
            case .other: return "Other"
            case .preferNotToSay: return "Prefer not to say"
        }
    }
}
