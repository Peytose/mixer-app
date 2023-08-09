//
//  StudentMajor.swift
//  mixer
//
//  Created by Peyton Lyons on 8/9/23.
//

import SwiftUI

enum StudentMajor: Int, Codable, CustomStringConvertible, CaseIterable {
    case sciences
    case business
    case arts
    case computerScience
    case socialSciences
    case health
    case education
    case engineering
    case mathematics
    case undecided
    case other
    
    var stringVal: String {
        switch self {
        case .sciences : return "Sciences"
        case .business : return "Business"
        case .arts : return "Arts"
        case .computerScience : return "Computer Science"
        case .socialSciences : return "Social Sciences"
        case .health : return "Health"
        case .education : return "Education"
        case .engineering : return "Engineering"
        case .mathematics : return "Mathematics"
        case .undecided : return "Undecided"
        case .other : return "Other"
        }
    }
    
    var icon: String {
        switch self {
            case .sciences: return "magnifyingglass"
            case .business: return "briefcase"
            case .arts: return "paintpalette"
            case .computerScience: return "desktopcomputer"
            case .socialSciences: return "person.3"
            case .health: return "cross"
            case .education: return "book.closed"
            case .engineering: return "gear"
            case .mathematics: return "sum"
            case .undecided: return "questionmark.circle"
            case .other: return "ellipsis.circle"
        }
    }
}
