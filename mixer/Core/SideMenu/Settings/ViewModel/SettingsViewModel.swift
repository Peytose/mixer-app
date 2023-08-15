//
//  SettingsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 7/19/23.
//

import UIKit
import SwiftUI
import Firebase

enum ProfileSaveType {
    case displayName
    case image
    case bio
    case instagram
    case gender
    case relationship
    case major
    case ageToggle
    case unknown
}

class SettingsViewModel: ObservableObject {
    @Published var user: User
    @Published var displayName: String
    @Published var bio: String
    @Published var instagramHandle: String
    @Published var showAgeOnProfile: Bool
    @Published var genderStr: String
    @Published var relationshipStatusStr: String
    @Published var majorStr: String
    @Published var selectedImage: UIImage?
    private var phoneNumber: String { return Auth.auth().currentUser?.phoneNumber ?? "" }
    let privacyLink = "https://mixer.llc/privacy-policy/"
    let termsOfServiceLink = "https://mixer.llc/privacy-policy/"
    
    init(user: User) {
        self.user                  = user
        self.displayName           = user.displayName
        self.bio                   = user.bio ?? ""
        self.instagramHandle       = user.instagramHandle ?? ""
        self.showAgeOnProfile      = user.showAgeOnProfile
        self.genderStr             = user.gender.stringVal
        self.relationshipStatusStr = user.relationshipStatus?.stringVal ?? RelationshipStatus.preferNotToSay.stringVal
        self.majorStr              = user.major?.stringVal ?? StudentMajor.other.stringVal
    }
    
    
    func save(for type: ProfileSaveType) {
        self.save(for: type) {
            HapticManager.playSuccess()
            AuthViewModel.shared.updateCurrentUser(user: self.user)
        }
    }
    
    private func save(for type: ProfileSaveType, completion: @escaping () -> Void) {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        
        switch type {
        case .displayName:
            guard self.displayName != "" else { return }
            
            COLLECTION_USERS.document(uid).updateData(["displayName": self.displayName]) { _ in
                self.user.displayName = self.displayName
                completion()
            }
            
        case .image:
            guard let image = self.selectedImage else {
                print("DEBUG: image not found.")
                return
            }
            
            ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
                COLLECTION_USERS.document(uid).updateData(["profileImageUrl": imageUrl]) { _ in
                    print("DEBUG: ✅ Succesfully updated profile image ...")
                    self.user.profileImageUrl = imageUrl
                    completion()
                }
            }
            
        case .bio:
            guard self.bio != "" else { return }
            
            COLLECTION_USERS.document(uid).updateData(["bio": self.bio]) { _ in
                self.user.bio = self.bio
                completion()
            }
            
        case .instagram:
            guard self.instagramHandle != "" else { return }
            
            COLLECTION_USERS.document(uid).updateData(["instagramHandle": self.instagramHandle]) { _ in
                self.user.instagramHandle = self.instagramHandle
                completion()
            }
            
        case .gender:
            guard self.genderStr != user.gender.stringVal else { return }
            guard let gender = Gender.enumCase(from: genderStr) else { return }
            
            COLLECTION_USERS.document(uid).updateData(["gender": gender.rawValue]) { _ in
                self.user.gender = gender
                completion()
            }
            
        case .relationship:
            guard relationshipStatusStr != user.relationshipStatus?.stringVal else { return }
            guard let relationshipStatus = RelationshipStatus.enumCase(from: relationshipStatusStr) else { return }
            
            COLLECTION_USERS.document(uid).updateData(["relationshipStatus": relationshipStatus.rawValue]) { _ in
                self.user.relationshipStatus = relationshipStatus
                completion()
            }
            
        case .major:
            guard majorStr != user.major?.stringVal else { return }
            guard let major = StudentMajor.enumCase(from: majorStr) else { return }
            
            COLLECTION_USERS.document(uid).updateData(["major": major.rawValue]) { _ in
                self.user.major = major
                completion()
            }
            
        case .ageToggle:
            COLLECTION_USERS.document(uid).updateData(["showAgeOnProfile": showAgeOnProfile]) { _ in
                self.user.showAgeOnProfile = self.showAgeOnProfile
                completion()
            }
            
        case .unknown:
            break
        }
    }
    
    
    func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    
    func getDateJoined() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        let days = formatter.string(from: user.dateJoined.dateValue(), to: Date()) ?? ""
        let date = user.dateJoined.getTimestampString(format: "MMMM d, yyyy")
        
        return "You joined mixer \(days) ago on \(date)."
    }
}

// Helper functions
extension SettingsViewModel {
    // Mapping content based on the row title
    func content(for title: String) -> Binding<String> {
        switch title {
        case "Display Name":
            return Binding<String>(get: { self.displayName }, set: { self.displayName = $0 })
        case "Bio":
            return Binding<String>(get: { self.bio }, set: { self.bio = $0 })
        case "Instagram":
            return Binding<String>(get: { self.instagramHandle }, set: { self.instagramHandle = $0 })
        case "Gender":
            return Binding<String>(get: { self.genderStr }, set: { self.genderStr = $0 })
        case "Relationship Status":
            return Binding<String>(get: { self.relationshipStatusStr }, set: { self.relationshipStatusStr = $0 })
        case "Major":
            return Binding<String>(get: { self.majorStr }, set: { self.majorStr = $0 })
        case "Name":
            return .constant(user.name)
        case "Username":
            return .constant(user.username)
        case "Email":
            return .constant(user.email)
        case "Phone":
            return .constant(self.phoneNumber)
        case "Version":
            return .constant(self.getVersion())
        default:
            return .constant("")
        }
    }
    
    // Mapping saveType based on the row title
    func saveType(for title: String) -> ProfileSaveType {
        switch title {
            case "Display Name":
                return .displayName
            case "Bio":
                return .bio
            case "Instagram":
                return .instagram
            case "Gender":
                return .gender
            case "Relationship Status":
                return .relationship
            case "Major":
                return .major
            case "Show age on profile?":
                return .ageToggle
            default:
                return .unknown
        }
    }
    
    // Mapping toggle based on the row title
    func toggle(for title: String) -> Binding<Bool> {
        switch title {
        case "Show age on profile?":
            return Binding<Bool>(
                get: { self.showAgeOnProfile },
                set: { self.showAgeOnProfile = $0 }
            )
        default:
            return .constant(false)
        }
    }
    
    // Mapping URLs based on the row title
    func url(for title: String) -> String {
        switch title {
        case "Privacy Policy":
            return privacyLink
        case "Terms of Service":
            return termsOfServiceLink
        default:
            return ""
        }
    }
}
