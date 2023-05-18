//
//  CreateEventViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import MapKit

enum CheckInMethod: String, Codable, CaseIterable, IconRepresentable {
    case qrCode   = "QR Code"
    case manual   = "Manual"
    case outOfApp = "Out-of-app"
    
    var icon: String {
        switch self {
        case .qrCode: return "qrcode"
        case .manual: return "pencil.line"
        case .outOfApp: return ""
        }
    }
    
    var description: String {
        switch self {
        case .qrCode:
            return "Guests can use the app to scan a QR code at the event to check in quickly and easily."
        case .manual:
            return "Hosts can manually check in guests by entering their information into a form within the app. This option is useful for guests who don't have the app or can't scan a QR code."
        case .outOfApp:
            return "Hosts can handle check-in outside the app. This option is useful if hosts are using a third-party check-in system or if they prefer to handle check-in manually outside the app."
        }
    }
}

final class CreateEventViewModel: ObservableObject {
    @Published var title: String                       = ""
    @Published var description: String                 = ""
    @Published var notes: String                       = ""
    @Published var hasNote: Bool                       = false
    @Published var guestLimit: String                  = ""
    @Published var guestInviteLimit: String            = ""
    @Published var memberInviteLimit: String           = ""
    @Published var startDate: Date                     = Date()
    @Published var endDate: Date                       = Date().addingTimeInterval(80600)
    @Published var address: String                     = ""
    @Published var previewCoordinates: CLLocationCoordinate2D?
    @Published var publicAddress: String               = ""
    @Published var selectedAmenities: Set<EventAmenities> = []
    @Published var type: EventType                     = .party
    @Published var eventOptions: [String: Bool]        = ["containsAlcohol": false,
                                                          "isInviteOnly": false,
                                                          "isPrivate": false,
                                                          "hasPublicAddress": false,
                                                          "isManualApprovalEnabled": false,
                                                          "isGuestLimitEnabled": false,
                                                          "isWaitlistEnabled": false,
                                                          "isMemberInviteLimitEnabled": false,
                                                          "isGuestInviteLimitEnabled": false,
                                                          "isRegistrationDeadlineEnabled": false,
                                                          "isCheckInEnabled": false]
    @Published var isLoading: Bool                     = false
    @Published var active: Screen                      = Screen.allCases.first!
    
    @Published var registrationDeadlineDate: Date?
    @Published var checkInMethod: CheckInMethod?       = .manual
    @Published var image: UIImage?
    
    @Published var cost: Float?
    @Published var alcoholPresence: Bool?
    @Published var bathroomCount: Int                  = 0
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
            case .costAndAmenities: return "Amenities"
            case .review: return "Review Event"
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
            
            var data: [String: Any] = ["title": self.title,
                                       "description": self.description,
                                       "hostUuid": host.id as String? ?? "",
                                       "hostName": host.name,
                                       "guestLimit": self.guestLimit,
                                       "guestInviteLimit": self.guestInviteLimit,
                                       "memberInviteLimit": self.memberInviteLimit,
                                       "startDate": Timestamp(date: self.startDate),
                                       "endDate": Timestamp(date: self.endDate),
                                       "address": self.address,
                                       "amenities": Array(self.selectedAmenities.map { $0.rawValue }),
                                       "eventOptions": self.eventOptions,
                                       "registrationDeadlineDate": Timestamp(date: self.registrationDeadlineDate ?? self.endDate),
                                       "eventImageUrl": imageUrl,
                                       "type": self.type.rawValue,
                                       "cost": self.cost as Float? ?? 0,
                                       "timePosted": Timestamp()]
            
            if self.notes != "" { data["notes"] = self.notes }
            if self.publicAddress != "" { data["publicAddress"] = self.publicAddress }
            
            if let checkInMethod = self.checkInMethod?.rawValue {
                data["checkInMethod"] = checkInMethod
            }
            
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
