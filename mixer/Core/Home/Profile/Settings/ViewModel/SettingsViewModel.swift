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
    case email
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
    @Published var email: String           = ""
    @Published var instagramHandle: String = ""
    @Published var showAgeOnProfile: Bool  = false
    @Published var genderStr: String       = ""
    @Published var datingStatusStr: String = ""
    @Published var majorStr: String        = ""
    @Published var isLoading               = false
    @Published var alertItem: AlertItem?
    
    private var phoneNumber: String { return Auth.auth().currentUser?.phoneNumber ?? "" }
    private var universityId: String = ""
    
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
                self.email = user.email ?? ""
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
            print("DEBUG: Saving bio......")
            guard updatedBio != self.bio else { return }
            
            guard updatedBio != "" else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["bio": updatedBio]) { _ in
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
            
        case .email:
            guard self.email.isValidEmail else { return }
            
            COLLECTION_USERS
                .document(uid)
                .updateData(["email": email]) { _ in
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
            return Binding<String>(get: { self.email }, set: { self.email = $0 })
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
            case "Email":
                return .email
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

    
    func shouldShowRow(withTitle title: String) -> Bool {
        // Example condition for "Connect Email" row
        if title.contains("Connect") && !(email.isEmpty) {
            // Don't show the row if the email is connected (not empty)
            return false
        }
        // Add other conditions for different rows as needed
        // Return true for rows that don't have specific conditions and should always be shown
        return true
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
        case "Connect Email":
            EnterEmailView(viewModel: self)
        default: ComingSoonView()
        }
    }
}

extension SettingsViewModel {
    private func fetchUniversity(completion: @escaping (Bool) -> Void) {
        if !email.isValidEmail {
            completion(false)
            return
        }
        
        let emailComponents = email.split(separator: "@")
        if emailComponents.count != 2 {
            completion(false)
            return
        }
        
        let domain = String(emailComponents[1])
        print("DEBUG: Domain from email: \(domain)")
        
        if domain.contains(".com") {
            universityId = "com"
            completion(true)
        }
        
        let queryKey = QueryKey(collectionPath: "universities",
                                filters: ["domain == \(domain)"])
        
        COLLECTION_UNIVERSITIES
            .whereField("domain", isEqualTo: domain)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 86400) { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting domain from email. \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let documents = snapshot?.documents, let document = documents.first else {
                    completion(false)
                    return
                }
                
                self.universityId = document.documentID
                completion(true)
            }
    }
    
    
    func sendVerificationEmail() {
        showLoadingView()
        
        fetchUniversity { success in
            guard success else {
                self.hideLoadingView()
                self.alertItem = AlertContext.unableToSendEmailLink
                return
            }
            
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://mixer.page.link/email-login?email=\(self.email)")
            actionCodeSettings.handleCodeInApp = true
            
            Auth.auth().sendSignInLink(toEmail: self.email, actionCodeSettings: actionCodeSettings) { error in
                if let error = error as? NSError {
                    self.handleAuthError(error)
                    return
                }
                
                self.hideLoadingView()
                self.alertItem = AlertContext.sentEmailLink
            }
        }
    }
    
    
    func handleUrl(_ url: URL) {
        print("Handling URL: \(url)")
        self.handleVerificationEmail(url) { success in
            if success {
                print("Email verification successful. Saving email...")
                self.save(for: .email)
            } else {
                print("Email verification failed.")
                HapticManager.playLightImpact()
            }
        }
    }

    private func handleVerificationEmail(_ url: URL, completion: @escaping (Bool) -> Void) {
        showLoadingView()
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let linkParam = queryItems.first(where: { $0.name == "link" }),
              let linkString = linkParam.value,
              let linkUrl = URL(string: linkString),
              let linkQueryItems = URLComponents(url: linkUrl, resolvingAgainstBaseURL: true)?.queryItems,
              let continueUrlParam = linkQueryItems.first(where: { $0.name == "continueUrl" })?.value,
              let continueUrl = URL(string: continueUrlParam),
              let continueUrlComponents = URLComponents(url: continueUrl, resolvingAgainstBaseURL: true),
              let emailQueryItem = continueUrlComponents.queryItems?.first(where: { $0.name == "email" }) else {
            print("Failed to extract email or continueUrl from the link.")
            hideLoadingView()
            completion(false)
            return
        }
        
        // Ensure the email from the URL matches the expected email format.
        guard emailQueryItem.value?.isValidEmail ?? false else {
            print("Extracted email is not in valid format.")
            hideLoadingView()
            completion(false)
            return
        }

        let email = emailQueryItem.value!
        print("Extracted email: \(email)")
        
        let link = url.absoluteString
        let credential = EmailAuthProvider.credential(withEmail: email, link: link)
        
        Auth.auth().currentUser?.link(with: credential) { authResult, error in
            if let error = error {
                print("Firebase Auth linking error: \(error.localizedDescription)")
                self.handleAuthError(error as NSError)
                completion(false)
                return
            }
            
            print("Firebase Auth linking successful.")
            self.hideLoadingView()
            completion(true)
        }
    }


    private func handleAuthError(_ error: NSError) {
        hideLoadingView()
        let errorCode = AuthErrorCode(_nsError: error)
        
        switch errorCode.code {
        case .invalidCredential:
            print("Auth Error: Invalid Credential")
            alertItem = AlertContext.invalidCredential
        case .emailAlreadyInUse:
            print("Auth Error: Email Already in Use")
            alertItem = AlertContext.emailAlreadyInUse
        case .invalidEmail:
            print("Auth Error: Invalid Email")
            alertItem = AlertContext.invalidEmail
        case .tooManyRequests:
            print("Auth Error: Too Many Requests")
            alertItem = AlertContext.tooManyRequests
        case .userNotFound:
            print("Auth Error: User Not Found")
            alertItem = AlertContext.userNotFound
        case .networkError:
            print("Auth Error: Network Error")
            alertItem = AlertContext.networkError
        case .credentialAlreadyInUse:
            print("Auth Error: Credential Already in Use")
            alertItem = AlertContext.credentialAlreadyInUse
        case .captchaCheckFailed:
            print("Auth Error: Captcha Check Failed")
            break
        default:
            print("Unspecified Auth Error: \(error.localizedDescription)")
            alertItem = AlertContext.unspecifiedAuthError
        }
    }

    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
