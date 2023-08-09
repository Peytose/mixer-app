//
//  EventFlowViewState.swift
//  mixer
//
//  Created by Peyton Lyons on 7/29/23.
//

import Foundation

enum EventFlowViewState: Int, Codable, CaseIterable {
    case basicInfo
    case locationAndDates
    case guestsAndInvitations
    case costAndAmenities
    case review
    
    var title: String {
        switch self {
            case .basicInfo: return "Basic Info"
            case .locationAndDates: return "Location & Dates"
            case .guestsAndInvitations: return "Guests & Invitations"
            case .costAndAmenities: return "Amenities"
            case .review: return "Review Event"
        }
    }
}
