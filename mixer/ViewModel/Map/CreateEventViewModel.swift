//
//  CreateEventViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import CloudKit
import SwiftUI

final class CreateEventViewModel: ObservableObject {
    @Published var title                    = ""
    @Published var description              = ""
    @Published var guestLimit               = ""
    @Published var guestInviteLimit         = ""
    @Published var memberInviteLimit        = ""
    @Published var startDate                = Date().addingTimeInterval(80600)
    @Published var endDate                  = Date()
    @Published var address                  = ""
    @Published var active                   = Screen.allCases.first!
    @Published var selectedAmenities        = Set<EventAmenities>()
    @Published var isInviteOnly             = false
    @Published var isLoading                = false
    @Published var privacy                  = PrivacyType.open { didSet { isInviteOnly.toggle() } }
    
    @Published var registrationDeadlineDate: Date?
    @Published var checkInMethod: CreateEventViewModel.CheckInMethod?
    @Published var image: UIImage?
    @Published var type: EventType?
    @Published var cost: Float?
    @Published var alcoholPresence: Bool?
    @Published var alertItem: AlertItem?
    
    let coordinates = CLLocationCoordinate2D(latitude: 42.3507046, longitude: -71.0909822)
    
    enum Screen: Int, CaseIterable {
        case basicInfo
        case locationAndDates
        case guestsAndInvitations
        case costAndAmenities
        case review
        
        var ScreenTitle: String {
            switch self {
            case .basicInfo: return "Basic Info"
            case .locationAndDates: return "Location & Dates"
            case .guestsAndInvitations: return "Guests & Invitations"
            case .costAndAmenities: return "Cost & Amenities"
            case .review: return "Review Event"
            }
        }
    }
    
    enum PrivacyType: String, CaseIterable {
        case open       = "Open"
        case inviteOnly = "Invite-only"
        
        var privacyIcon: String {
            switch self {
            case .open: return "envelope.open"
            case .inviteOnly: return "envelope"
            }
        }
    }
    
    enum CheckInMethod: String, CaseIterable {
        case qrCode = "QR Code"
        case manual = "Manual"
        
        var checkInIcon: String {
            switch self {
            case .qrCode: return "qrcode"
            case .manual: return "rectangle.and.pencil.and.ellipsis"
            }
        }
    }

    
    func next() {
        let nextScreenIndex = min(active.rawValue + 1, Screen.allCases.last!.rawValue)
        if let screen = Screen(rawValue: nextScreenIndex) { active = screen }
    }
    
    
    func previous() {
        let previousScreenIndex = max(active.rawValue - 1, Screen.allCases.first!.rawValue)
        if let screen = Screen(rawValue: previousScreenIndex) { active = screen }
    }
    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
