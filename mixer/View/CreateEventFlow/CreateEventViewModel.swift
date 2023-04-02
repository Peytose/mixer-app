//
//  CreateEventViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

final class CreateEventViewModel: ObservableObject {
    @Published var title: String                       = ""
    @Published var description: String                 = ""
    @Published var guestLimit: String                  = ""
    @Published var guestInviteLimit: String            = ""
    @Published var memberInviteLimit: String           = ""
    @Published var startDate: Date                     = Date().addingTimeInterval(80600)
    @Published var endDate: Date                       = Date()
    @Published var address: String                     = ""
    @Published var selectedAmenities: Set<EventAmenities> = []
    @Published var type: EventType                     = .kickback
    @Published var privacy: PrivacyType                = .open
    @Published var isManualApprovalEnabled: Bool       = false
    @Published var isGuestLimitEnabled: Bool           = false
    @Published var isWaitlistEnabled: Bool             = false
    @Published var isMemberInviteLimitEnabled: Bool    = false
    @Published var isGuestInviteLimitEnabled: Bool     = false
    @Published var isRegistrationDeadlineEnabled: Bool = false
    @Published var isCheckInOptionsEnabled: Bool       = false
    @Published var isLoading: Bool                     = false
    @Published var active: Screen                      = Screen.allCases.first!
    
    @Published var registrationDeadlineDate: Date?
    @Published var checkInMethod: CreateEventViewModel.CheckInMethod?
    @Published var image: UIImage?
    
    @Published var cost: Float?
    @Published var alcoholPresence: Bool?
    @Published var alertItem: AlertItem?
    
    enum Screen: Int, Codable, CaseIterable {
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
    
    enum PrivacyType: String, Codable, CaseIterable {
        case open       = "Open"
        case inviteOnly = "Invite-only"
        
        var privacyIcon: String {
            switch self {
            case .open: return "envelope.open"
            case .inviteOnly: return "envelope"
            }
        }
    }
    
    enum CheckInMethod: String, Codable, CaseIterable {
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
    
    
    func createEvent() {
        print("DEBUG: Register button tapped!")
        guard let image = image else {
            print("DEBUG: image not found.")
            return
        }
        
        print("DEBUG: Image found.")
        
        ImageUploader.uploadImage(image: image, type: .event) { imageUrl in
            // Needs attention (issue: only allows users to be single host)
            guard let host = AuthViewModel.shared.hosts.first else {
                print("DEBUG: No host associated with user.")
                return
            }
            
            let data: [String: Any] = ["title": self.title,
                                       "description": self.description,
                                       "hostUuid": host.id as Any,
                                       "hostUsername": host.username,
                                       "guestLimit": self.guestLimit,
                                       "guestInviteLimit": self.guestInviteLimit,
                                       "memberInviteLimit": self.memberInviteLimit,
                                       "startDate": Timestamp(date: self.startDate),
                                       "endDate": Timestamp(date: self.endDate),
                                       "address": self.address,
                                       "selectedAmenities": Array(self.selectedAmenities.map { $0.rawValue }),
                                       "privacy": self.privacy.rawValue,
                                       "isManualApprovalEnabled": self.isManualApprovalEnabled,
                                       "isGuestLimitEnabled": self.isGuestLimitEnabled,
                                       "isWaitlistEnabled": self.isWaitlistEnabled,
                                       "isMemberInviteLimitEnabled": self.isMemberInviteLimitEnabled,
                                       "isGuestInviteLimitEnabled": self.isGuestInviteLimitEnabled,
                                       "isRegistrationDeadlineEnabled": self.isRegistrationDeadlineEnabled,
                                       "isCheckInOptionsEnabled": self.isCheckInOptionsEnabled,
                                       "registrationDeadlineDate": Timestamp(date: self.registrationDeadlineDate ?? self.endDate),
                                       "checkInMethod": self.checkInMethod?.rawValue as Any,
                                       "eventImageUrl": imageUrl,
                                       "type": self.type.rawValue,
                                       "cost": self.cost as Any,
                                       "alcoholPresence": self.alcoholPresence as Any,
                                       "timePosted": Timestamp()]
            
            let newDocRef = COLLECTION_EVENTS.addDocument(data: data) { error in
                if let error = error {
                    print("DEBUG: Error uploading event. \(error.localizedDescription)")
                    return
                }
                
                print("DEBUG: Succesfully uploaded event ...")
            }
            
            newDocRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching event. \(error.localizedDescription)")
                }
                
                guard let event = try? snapshot?.data(as: Event.self) else { return }
                try? EventCache.shared.cacheEvent(CachedEvent(from: event))
            }
        }
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
