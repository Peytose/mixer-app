//
//  SettingsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 7/19/23.
//

import UIKit
import SwiftUI
import Firebase
import Combine

enum SettingSaveType {
    case displayName
    case image(UIImage)
    case bio(String)
    case instagram
    case description(String)
    case address
    case locationToggle
    case location
    // User-specific save types
    case gender
    case relationship
    case major
    case ageToggle
    // Host-specific save types
    case website
    // Event-specific save types
    case title
    case note(String)
    case amenities
    case startDate
    case endDate
    case unknown
}

class SettingsViewModel: SettingsConfigurable {
    @Published var user: User?
    @Published var displayName: String     = ""
    @Published var bio: String             = ""
    @Published var instagramHandle: String = ""
    @Published var showAgeOnProfile: Bool  = false
    @Published var genderStr: String       = ""
    @Published var datingStatusStr: String = ""
    @Published var majorStr: String        = ""
    private var phoneNumber: String { return Auth.auth().currentUser?.phoneNumber ?? "" }
    
    let privacyLink = "https://rococo-gumdrop-0f32da.netlify.app"
    let termsOfServiceLink = "https://mixer.llc/privacy-policy/"
    
    private let service = UserService.shared
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        self.fetchUser()
    }
    
    
    // MARK: - User API
    func fetchUser() {
        service.$user
            .sink { user in
                self.user = user
                guard let user = user else { return }
                
                self.displayName = user.displayName
                self.bio = user.bio ?? ""
                self.instagramHandle = user.instagramHandle ?? ""
                self.showAgeOnProfile = user.showAgeOnProfile
                self.genderStr = user.gender.description
                self.datingStatusStr = user.datingStatus?.description ?? ""
            }
            .store(in: &cancellable)
    }
    
    
    func save(for type: SettingSaveType) {
        self.save(for: type) {
            print("DEBUG: \(type.self) saved!")
            HapticManager.playSuccess()
        }
    }
    
    
    private func save(for type: SettingSaveType, completion: @escaping () -> Void) {
        guard let uid = UserService.shared.user?.id else { return }
        
        switch type {
        case .displayName:
            guard self.displayName != "" else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["displayName": self.displayName]) { _ in
                    completion()
                }
            
        case .image(let selectedImage):
            ImageUploader.uploadImage(image: selectedImage, type: .profile) { imageUrl in
                COLLECTION_USERS
                    .document(uid)
                    .updateData(["profileImageUrl": imageUrl]) { _ in
                        completion()
                    }
            }
            
        case .bio(let updatedBio):
            guard updatedBio != self.bio, updatedBio != "" else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["bio": bio]) { _ in
                    completion()
                }
            
        case .instagram:
            guard self.instagramHandle != "" else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["instagramHandle": instagramHandle]) { _ in
                    completion()
                }
            
        case .gender:
            guard self.genderStr != user?.gender.description else { return }
            guard let gender = Gender.enumCase(from: genderStr) else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["gender": gender.rawValue]) { _ in
                    completion()
                }
            
        case .relationship:
            guard self.datingStatusStr != user?.datingStatus?.description else { return }
            guard let datingStatus = DatingStatus.enumCase(from: datingStatusStr) else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["datingStatus": datingStatus.rawValue]) { _ in
                    completion()
                }
            
        case .major:
            guard self.majorStr != user?.major?.description else { return }
            guard let major = StudentMajor.enumCase(from: majorStr) else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["major": major.rawValue]) { _ in
                    completion()
                }
            
        case .ageToggle:
            COLLECTION_USERS
                .document(uid)
                .updateData(["showAgeOnProfile": showAgeOnProfile]) { _ in
                    completion()
                }
            
        default:
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
        
        guard let user = self.user else { return "" }
        let days = formatter.string(from: user.dateJoined.dateValue(), to: Date()) ?? ""
        let date = user.dateJoined.getTimestampString(format: "MMMM d, yyyy")
        
        return "You joined mixer \(days) ago on \(date)."
    }
}

// Helper functions
extension SettingsViewModel {
    // Mapping content based on the row title
    func content(for title: String) -> Binding<String> {
        guard let user = self.user else { return .constant("") }
        
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
            return Binding<String>(get: { self.datingStatusStr }, set: { self.datingStatusStr = $0 })
        case "Major":
            return Binding<String>(get: { self.majorStr }, set: { self.majorStr = $0 })
        case "Name":
            return .constant(user.fullName)
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
    func saveType(for title: String) -> SettingSaveType {
        switch title {
            case "Display Name":
                return .displayName
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
    
    
    // Mapping destination based on the row title
    @ViewBuilder
    func destination(for title: String) -> some View {
        switch title {
        case "Bio":
            EditTextView(navigationTitle: "Edit Bio",
                                        title: "Bio",
                                        text: bio,
                                        limit: 150) { updatedText in
                self.save(for: .bio(updatedText))
            }
            default: ComingSoonView()
        }
    }
}
