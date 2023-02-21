//
//  CreateEventViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import CloudKit
import SwiftUI

enum WetOrDry: String {
    case wet, dry
    
    var stringVersion: String {
        switch self {
            case .wet: return "Wet"
            case .dry: return "Dry"
        }
    }
}

enum UseCustomAddress: String {
    case yes, no

    var stringVersion: String {
        switch self {
            case .yes: return "Custom Address"
            case .no: return "Default Address"
        }
    }
}

enum isPrivate: String {
    case yes, no
    
    var stringVersion: String {
        switch self {
            case .yes: return "Private"
            case .no: return "Public"
        }
    }
}

    @MainActor final class CreateEventViewModel: ObservableObject {
        @Published var title                             = ""
        @Published var description                       = ""
        @Published var startDate                         = Date()
        @Published var endDate                           = Date()
        @Published var selectedWetDry: WetOrDry          = .dry
        @Published var selectedAddress: UseCustomAddress = .no
        @Published var isPrivate:    isPrivate           = .no
        @Published var theme                             = ""
        @Published var themeDescription                  = ""
        @Published var guestLimit                        = ""
        @Published var guestLimitForGuests               = ""
        @Published var address                           = ""
        @Published var attireDescription                 = ""
        @Published var note                              = ""

        @Published var flyer                             = PlaceholderImage.event
        
        @Published var showEndDate                       = false
        @Published var includeDescription                = false
        @Published var hasFlyer                          = false
        @Published var isShowingPhotoPicker              = false
        @Published var isLoading                         = false
        @Published var isInviteLimit                     = false
        @Published var hasAttireDescription              = false
        @Published var hasNote                           = false
        @Published var isGuestInviteLimit                = false
        @Published var includeInviteList                 = false
        @Published var showAttendanceCount               = false
        @Published var alertItem: AlertItem?
        
        let coordinates = CLLocationCoordinate2D(latitude: 42.3507046, longitude: -71.0909822)

        
//        private func isValidEvent() -> Bool {
//            guard !title.isEmpty,
//                  !description.isEmpty,
//                  flyer != PlaceholderImage.avatar,
//                  description.count <= 100 else { return false }
//
//            return true
//        }
        
        
//        private func resetFields() {
//            title               = ""
//            description         = ""
//            startDate           = Date()
//            endDate             = Date()
//            selectedWetDry      = .dry
//            isInviteOnly        = .no
//            theme               = ""
//            themeDescription    = ""
//            guestLimit          = ""
//            guestLimitForGuests = ""
//            flyer               = PlaceholderImage.avatar
//            showEndDate         = false
//            includeDescription  = false
//            isInviteLimit       = false
//            isGuestInviteLimit  = false
//        }
        
        
//        func createEvent() {
//            guard isValidEvent() else {
//                alertItem = AlertContext.invalidEvent
//                return
//            }
//
//            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
//                alertItem = AlertContext.unableToGetProfile
//                return
//            }
//
//            showLoadingView()
//
//            Task {
//                do {
//                    let creatorRecord = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
//
//                    let eventRecord = createEventRecord(creator: creatorRecord)
//
//                    let _ = try await CloudKitManager.shared.save(record: eventRecord)
//                    hideLoadingView()
//                    alertItem = AlertContext.createEventSuccess
//                    resetFields()
//                } catch {
//                    hideLoadingView()
//                    alertItem = AlertContext.createEventFailure
//                    print("❌❌❌❌\(error.localizedDescription)❌❌❌❌")
//                }
//            }
//        }
        
        
//        private func createEventRecord(creator: CKRecord) -> CKRecord {
//            let eventRecord = CKRecord(recordType: RecordType.event)
//            eventRecord[EventRecord.kTitle]            = title
//            eventRecord[EventRecord.kDescription]      = description
//            eventRecord[EventRecord.kStartDate]        = startDate
//            eventRecord[EventRecord.kEndDate]          = endDate
//            eventRecord[EventRecord.kInviteOnly]       = isInviteOnly.stringVersion
//            eventRecord[EventRecord.kWetOrDry]         = selectedWetDry.stringVersion
//            eventRecord[EventRecord.kTheme]            = theme
//            eventRecord[EventRecord.kThemeDescription] = themeDescription
//            eventRecord[EventRecord.kFlyer]            = flyer.convertToCKAsset()
//            eventRecord[EventRecord.kCreatorName]      = "\(creator[UserProfile.kFirstName] ?? "n/a") \(creator[UserProfile.kLastName] ?? "n/a")"
//            eventRecord[EventRecord.kOrganization]     = creator[UserProfile.kHasHostStatus]
//
//            //MARK: Suggestion
//            /*
//             create new eventRecord for:
//             guestLimit
//             guestLimitForGuests
//
//             Delete the theme one since we dont use it anymore
//             What is themeDescription
//             */
//            return eventRecord
//        }
        
        
        private func showLoadingView() { isLoading = true }
        private func hideLoadingView() { isLoading = false }
    }
