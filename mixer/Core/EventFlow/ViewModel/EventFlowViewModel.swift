////
////  EventFlowViewModel.swift
////  mixer
////
////  Created by Jose Martinez on 12/18/22.
////
//
//import SwiftUI
//import FirebaseFirestoreSwift
//import Firebase
//import MapKit
//
//final class EventFlowViewModel: ObservableObject {
//    @Published var title: String                       = ""
//    @Published var description: String                 = ""
//    @Published var note: String                        = ""
//    @Published var guestLimitStr: String               = ""
//    @Published var guestInviteLimitStr: String         = ""
//    @Published var memberInviteLimitStr: String        = ""
//    @Published var startDate: Date                     = Date()
//    @Published var endDate: Date                       = Date().addingTimeInterval(80600)
//    @Published var address: String                     = ""
//    @Published var altAddress: String                  = ""
//    @Published var selectedAmenities: Set<EventAmenities> = []
//    @Published var type: EventType                     = .party
//    @Published var isLoading: Bool                     = false
//    @Published var viewState: EventFlowViewState       = .basicInfo
//    @Published var isInviteOnly: Bool                  = false
//    @Published var isPrivate: Bool                  = false
//    @Published var isManualApprovalEnabled: Bool       = false
//    @Published var isGuestlistEnabled: Bool            = false
//    
//    @Published var registrationDeadlineDate: Date?
//    @Published var checkInMethod: CheckInMethod?       = .manual
//    @Published var selectedImage: UIImage?
//    @Published var coordinates: CLLocationCoordinate2D?
//    
//    @Published var cost: Float?
//    @Published var alcoholPresence: Bool?
//    @Published var bathroomCount: Int                  = 0
//    @Published var alertItem: AlertItem?
//    
//    var isFormValid: Bool {
//        switch viewState {
//        case .basicInfo:
//            return selectedImage != nil ||
//            !title.isEmpty ||
//            !description.isEmpty ||
//            title.count <= 50 ||
//            description.count >= 150 ||
//            note.count >= 250
//        default:
//            return true
//        }
//    }
//    
//    
//    func actionForState() {
//        switch self.viewState {
//        case .basicInfo,
//                .locationAndDates,
//                .guestsAndInvitations,
//                .costAndAmenities:
//            guard let nextView = EventFlowViewState(rawValue: viewState.rawValue + 1) else { return }
//            self.viewState = nextView
//        case .review:
//            self.createEvent()
//        }
//    }
//    
//    
//    func viewForState() -> some View {
//        switch self.viewState {
//        case .basicInfo:
//            return AnyView(BasicEventInfo())
//        case .locationAndDates:
//            return AnyView(EventLocationAndDates())
//        case .guestsAndInvitations:
//            return AnyView(EventGuestsAndInvitations())
//        case .costAndAmenities:
//            return AnyView(EventAmenitiesAndCost())
//        case .review:
//            return AnyView(ReviewCreatedEventView())
//        }
//        
//        return AnyView(Text(""))
//    }
//    
//    
//    func createEvent() {
//        guard let image = selectedImage else {return }
//        
//        ImageUploader.uploadImage(image: image, type: .event) { imageUrl in
//            // Needs attention (issue: only allows users to be single host)
//            guard let host = AuthViewModel.shared.currentUser?.associatedHosts?.first, let hostUid = host.id else { return }
//            guard let uid = Auth.auth().currentUser?.uid else { return }
//            
//            self.address.getLocation { location, _ in
//                guard let location = location else { return }
//                let geoPoint       = GeoPoint(latitude: location.coordinate.latitude,
//                                              longitude: location.coordinate.longitude)
//                
//                let event          = Event(hostId: hostUid,
//                                           hostName: host.name,
//                                           timePosted: Timestamp(),
//                                           eventImageUrl: imageUrl,
//                                           title: self.title,
//                                           description: self.description,
//                                           type: self.type,
//                                           note: self.note.isEmpty ? nil : self.note,
//                                           address: self.address,
//                                           altAddress: self.altAddress.isEmpty ? nil : self.altAddress,
//                                           geoPoint: geoPoint,
//                                           amenities: self.selectedAmenities.isEmpty ? nil : Array(self.selectedAmenities),
//                                           checkInMethods: self.checkInMethod != nil ? [self.checkInMethod!] : nil,
//                                           containsAlcohol: self.alcoholPresence ?? false,
//                                           startDate: Timestamp(date: self.startDate),
//                                           endDate: Timestamp(date: self.endDate),
//                                           registrationDeadlineDate: self.registrationDeadlineDate != nil ? Timestamp(date: self.registrationDeadlineDate!) : nil,
//                                           favoritedBy: [],
//                                           guestLimit: Int(self.guestLimitStr),
//                                           guestInviteLimit: Int(self.guestInviteLimitStr),
//                                           memberInviteLimit: Int(self.memberInviteLimitStr),
//                                           isInviteOnly: self.isInviteOnly,
//                                           isManualApprovalEnabled: self.isManualApprovalEnabled,
//                                           isGuestlistEnabled: self.isGuestlistEnabled,
//                                           isWaitlistEnabled: self.isWaitlistEnabled,
//                                           cost: self.cost)
//                
//                guard let encodedEvent = try? Firestore.Encoder().encode(event) else { return }
//                
//                COLLECTION_EVENTS.addDocument(data: encodedEvent)
//            }
//        }
//    }
//    
//    private func showLoadingView() { isLoading = true }
//    private func hideLoadingView() { isLoading = false }
//}
