//
//  HostSettingsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 11/18/23.
//

import SwiftUI

class HostSettingsViewModel: SettingsConfigurable {
    @Published var hostImageUrl: String
    @Published var displayName: String
    @Published private(set) var username: String
    @Published var instagramHandle: String
    @Published var website: String
    @Published var address: String
    @Published var showLocationOnProfile: Bool
    @Published var selectedImage: UIImage?
    
    private var description: String
    let hostAgreementLink = ""
    let privacyPolicyLink = ""
    
    init(host: Host) {
        self.hostImageUrl          = host.hostImageUrl
        self.displayName           = host.name
        self.username              = host.username
        self.instagramHandle       = host.instagramHandle ?? ""
        self.website               = host.website ?? ""
        self.description           = host.description
        self.address               = host.address ?? ""
        self.showLocationOnProfile = host.showLocationOnProfile
    }
}

// Helper functions
extension HostSettingsViewModel {
    func save(for type: ProfileSaveType) {
        self.save(for: type) {
            print("DEBUG: \(type.self) saved!")
            HapticManager.playSuccess()
        }
    }
    
    
    private func save(for type: ProfileSaveType, completion: @escaping () -> Void) {
        guard let uid = UserService.shared.user?.currentHost?.id else { return }
        
        switch type {
        case .displayName:
            guard self.displayName != "" else { return }
            
            COLLECTION_HOSTS
                .document(uid)
                .updateData(["name": self.displayName]) { _ in
                    UserService.shared.user?.currentHost?.name = self.displayName
                    completion()
                }
            
        case .image:
            guard let image = self.selectedImage else {
                print("DEBUG: image not found.")
                return
            }
            
            ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
                COLLECTION_HOSTS
                    .document(uid)
                    .updateData(["hostImageUrl": imageUrl]) { _ in
                        UserService.shared.user?.currentHost?.hostImageUrl = imageUrl
                        self.hostImageUrl = imageUrl
                        completion()
                    }
            }
            
        case .instagram:
            guard self.instagramHandle != "" else { return }
            
            COLLECTION_HOSTS
                .document(uid)
                .updateData(["instagramHandle": instagramHandle]) { _ in
                    UserService.shared.user?.currentHost?.instagramHandle = self.instagramHandle
                    completion()
                }
            
        case .website:
            guard self.website != "" else { return }
            
            COLLECTION_HOSTS
                .document(uid)
                .updateData(["website": website]) { _ in
                    UserService.shared.user?.currentHost?.website = self.website
                    completion()
                }
            
        case .description(let updatedDescription):
            guard updatedDescription != self.description, updatedDescription != "" else { return }
            
            COLLECTION_HOSTS
                .document(uid)
                .updateData(["description": updatedDescription]) { _ in
                    UserService.shared.user?.currentHost?.description = updatedDescription
                    completion()
                }
            
        case .address:
            guard self.address != "" else { return }
            
            print("DEBUG: Not implemented yet.")
            break
            
//            COLLECTION_HOSTS
//                .document(uid)
//                .updateData(["address": address]) { _ in
//                    completion()
//                }
            
        case .locationToggle:
            self.showLocationOnProfile = !showLocationOnProfile
            
            COLLECTION_HOSTS
                .document(uid)
                .updateData(["showLocationOnProfile": self.showLocationOnProfile]) { _ in
                    UserService.shared.user?.currentHost?.showLocationOnProfile = self.showLocationOnProfile
                    completion()
                }
            
        default:
            break
        }
    }
    
    
    // Mapping content based on the row title
    func content(for title: String) -> Binding<String> {
        switch title {
        case "Display Name":
            return Binding<String>(get: { self.displayName }, set: { self.displayName = $0 })
        case "Username":
            return .constant(self.username)
        case "Instagram":
            return Binding<String>(get: { self.instagramHandle }, set: { self.instagramHandle = $0 })
        case "Website":
            return Binding<String>(get: { self.website }, set: { self.website = $0 })
        case "Location":
            return Binding<String>(get: { self.address }, set: { self.address = $0 })
        default:
            return .constant("")
        }
    }
    
    
    // Mapping saveType based on the row title
    func saveType(for title: String) -> ProfileSaveType {
        switch title {
            case "Display Name":
                return .displayName
            case "Instagram":
                return .instagram
            case "Website":
                return .website
            case "Location":
                return .address
            case "Show location on profile?":
                return .locationToggle
            default:
                return .unknown
        }
    }
    
    
    // Mapping toggle based on the row title
    func toggle(for title: String) -> Binding<Bool> {
        switch title {
        case "Show location on profile?":
            return Binding<Bool>(
                get: { self.showLocationOnProfile },
                set: { self.showLocationOnProfile = $0 }
            )
        default:
            return .constant(false)
        }
    }
    
    
    // Mapping URLs based on the row title
    func url(for title: String) -> String {
        switch title {
        case "Host Agreement":
            return hostAgreementLink
        case "Privacy Policy":
            return privacyPolicyLink
        default:
            return ""
        }
    }
    
    
    // Mapping destination based on the row title
    func destination(for title: String) -> AnyView {
        switch title {
            case "Description":
                return AnyView(EditTextView(navigationTitle: "Edit Description",
                                            title: "Description",
                                            text: description,
                                            limit: 200) { updatedText in
                    self.save(for: .description(updatedText))
                })
            case "Edit Members":
                return AnyView(ManageMembersView())
            case "Address":
                return AnyView(EditAddressView())
            default: return AnyView(EmptyView())
        }
    }
}
