//
//  BecomeHostViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 2/24/24.
//

import SwiftUI
import MapKit
import Firebase

class BecomeHostViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var type: HostType = .fraternity
    @Published var eventTypes = Set<EventType>()
    @Published var address: String = ""
    @Published var coordinate: CLLocationCoordinate2D = .init(latitude: 42.35071, longitude: -71.09097)
    @Published var image: UIImage?
    @Published var tagline: String = ""
    @Published var contactEmail: String = ""
    @Published var username: String = "" {
        didSet {
            checkUsernameValidity()
        }
    }
    
    private var notificationId: String
    
    @Published var isUsernameValid: Bool = false
    @Published var useEmailForContact: Bool = false {
        didSet {
            if useEmailForContact, let email = userService.user?.email {
                contactEmail = email
            } else {
                contactEmail = ""
            }
        }
    }
    @Published var showPicker: Bool = false
    
    private var userService = UserService.shared
    
    init(notificationId: String) {
        self.notificationId = notificationId
    }
    
    
    func buttonMessage(for state: BecomeHostViewState) -> String? {
        switch state {
        case .nameAndDescription:
            return name.isEmpty ? "Enter your host's name to get started." :
                  description.isEmpty ? "Add a brief description next." :
                  "Ready to define your host type and events."
        case .hostAndEventInfo:
            return "Select at least one event type to proceed."
        case .pictureAndTagline:
            return image == nil ? "Add a face to your host profile." :
                  tagline.isEmpty ? "What's your catchphrase?" :
                  "Almost there! Just your contact info next."
        case .contactEmail:
            return contactEmail.isEmpty ? "We need a way to reach you. Add an email." :
                  !contactEmail.isValidEmail ? "Hmm, that doesn't look like an email." :
                  useEmailForContact ? "Using your account email. Next up, username!" :
                  "Great! Now, choose a unique username."
        case .username:
            return isUsernameValid ? "All set! Tap finish to create your host profile." :
                  "Choose a username with at least 4 characters."
        default: return nil
        }
    }
    
    
    func buttonText(for state: BecomeHostViewState) -> String {
        switch state {
        case .username:
            return "Finish"
        default: return "Continue"
        }
    }
    
    
    func isButtonActive(for state: BecomeHostViewState) -> Bool {
        switch state {
        case .nameAndDescription:
            return !name.isEmpty && (!description.isEmpty && description.count <= 150)
        case .hostAndEventInfo:
            return !eventTypes.isEmpty
        case .location:
            return true
        case .pictureAndTagline:
            return image != nil && !tagline.isEmpty
        case .contactEmail:
            return (!contactEmail.isEmpty && contactEmail.isValidEmail) || useEmailForContact
        case .username:
            return isUsernameValid
        }
    }
    
    
    func buttonAction(for state: inout BecomeHostViewState) {
        switch state {
        case .nameAndDescription,
                .pictureAndTagline,
                .contactEmail:
            state = state.advanced(by: 1)
        case .hostAndEventInfo:
            state = state.advanced(by: 1)
            self.showPicker = true
        case .location:
            self.showPicker = true
        case .username:
            self.createHost()
        }
    }
    
    
    func backArrowAction(for state: inout BecomeHostViewState) {
        state = state.advanced(by: -1)
    }
    
    
    func handleItem(_ item: MKMapItem?, state: inout BecomeHostViewState) {
        if let placemark = item?.placemark, !(placemark.title?.contains(address) ?? false) {
            self.address = placemark.title?.condenseWhitespace() ?? ""
            self.coordinate = placemark.coordinate
            state = state.advanced(by: 1)
        }
    }
    
    
    func createHost() {
        guard let user = userService.user, let userId = user.id, let image = self.image else { return }
        
        ImageUploader.uploadImage(image: image, type: .host) { hostImageUrl in
            let host = Host(mainUserId: userId,
                            contactEmail: self.contactEmail,
                            dateJoined: Timestamp(),
                            name: self.name,
                            username: self.username,
                            description: self.description,
                            hostImageUrl: hostImageUrl,
                            universityId: user.universityId,
                            type: self.type,
                            typesOfEvents: Array(self.eventTypes),
                            tagline: self.tagline,
                            address: self.address,
                            location: self.coordinate.toGeoPoint(),
                            showLocationOnProfile: true)
            
            guard let encodedHost = try? Firestore.Encoder().encode(host) else { return }
            
            // Declare the reference outside of the closure
            var hostReference: DocumentReference? = nil
            
            hostReference = COLLECTION_HOSTS.addDocument(data: encodedHost) { error in
                if let error = error {
                    print("DEBUG: Error creating host. \(error.localizedDescription)")
                    return
                }
                
                // Check if the reference was successfully created
                if let hostReference = hostReference {
                    COLLECTION_USERS.document(userId).updateData(["hostIdToMemberTypeMap.\(hostReference.documentID)": HostMemberType.admin.rawValue]) { error in
                        if let error = error {
                            print("DEBUG: Error saving host id to member type map on user. \(error.localizedDescription)")
                            return
                        }
                        
                        COLLECTION_NOTIFICATIONS
                            .document(userId)
                            .collection("user-notifications")
                            .document(self.notificationId)
                            .delete { _ in
                                self.userService.user?.currentHost = host
                                self.userService.user?.hostIdToMemberTypeMap?[hostReference.documentID] = .admin
                            }
                    }
                }
            }
        }
    }
    
    
    private func checkUsernameValidity() {
        let usernamePattern = "^[a-zA-Z0-9_]{4,}$" // Adjust pattern as needed
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernamePattern)
        
        if usernamePredicate.evaluate(with: self.username) {
            print("DEBUG: Username '\(self.username)' matches the pattern.")
        } else {
            print("DEBUG: Username '\(self.username)' does NOT match the pattern.")
            self.isUsernameValid = false
            return
        }
        
        AlgoliaManager.shared.validateUsername(self.username) { isValid in
            DispatchQueue.main.async {
                if isValid {
                    print("DEBUG: Username '\(self.username)' is valid according to AlgoliaManager.")
                } else {
                    print("DEBUG: Username '\(self.username)' is NOT valid according to AlgoliaManager.")
                }
                self.isUsernameValid = isValid
            }
        }
    }
}
