//
//  AuthViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 11/8/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import Combine

class AuthViewModel: ObservableObject {
    // User-Related Variables
    @Published var name            = ""
    @Published var displayName     = ""
    @Published var email           = ""
    @Published var phoneNumber     = ""
    @Published var countryCode     = ""
    @Published var code            = ""
    @Published var image: UIImage?
    @Published var bio             = ""
    @Published var birthdayStr     = "" { didSet { checkValidBirthday() } }
    @Published var birthday        = Date.now { didSet { isValidBirthday = true } }
    @Published var gender          = Gender.woman
    @Published var username        = ""
    @Published var universityId    = ""
    @Published var isValidBirthday = false
    
    // UI State Variables
    @Published var isLoading                  = false
    @Published var isOnboardingScreensVisible = false
    @Published var isLoggedOut                = false
    @Published var currentAlert: AlertType?
    @Published var alertItem: AlertItem? {
        didSet {
            currentAlert = .regular(alertItem)
        }
    }
    @Published var confirmationAlertItem: ConfirmationAlertItem? {
        didSet {
            currentAlert = .confirmation(confirmationAlertItem)
        }
    }
    
    // Other Properties
    private let service     = UserService.shared
    static let shared       = AuthViewModel()
    
    init() {
        DispatchQueue.main.async {
            self.isOnboardingScreensVisible = !self.hasShownOnboardingScreens()
            print("DEBUG: \(self.isOnboardingScreensVisible)")
        }
    }
    
    
    @MainActor
    func completeOnboarding() {
        setOnboardingScreensShown(true)
        isOnboardingScreensVisible = false
    }
    
    
    func viewForState(_ state: AuthFlowViewState) -> some View {
        switch state {
            case .enterName: return AnyView(EnterNameView())
            case .enterPhone: return AnyView(EnterPhoneNumberView())
            case .verifyCode: return AnyView(EnterVerificationCodeView())
            case .enterEmail: return AnyView(EnterEmailView())
            case .uploadProfilePicAndBio: return AnyView(EnterProfilePictureAndBioView())
            case .enterBirthday: return AnyView(EnterBirthdayView())
            case .selectGender: return AnyView(SelectGenderView())
            case .chooseUsername: return AnyView(EnterUsernameView())
        }
    }
    
    
    func actionForState(_ state: Binding<AuthFlowViewState>) {
        switch state.wrappedValue {
        case .enterName:
            self.next(state)
        case .enterPhone:
            self.startPhoneVerification { success in
                if success {
                    self.next(state)
                }
            }
        case .verifyCode:
            self.verifyCode { success in
                if success {
                    self.next(state)
                }
            }
        case .enterEmail:
            self.sendVerificationEmail()
        case .uploadProfilePicAndBio, .enterBirthday, .selectGender:
            self.next(state)
        case .chooseUsername:
            self.register()
        }
    }
    
    
    func isButtonActiveForState(_ state: AuthFlowViewState) -> Bool {
        switch state {
        case .enterName:
            return !name.isEmpty
        case .enterPhone:
            return !phoneNumber.isEmpty
        case .verifyCode:
            return !code.isEmpty
        case .enterEmail:
            return !email.isEmpty
        case .enterBirthday:
            return isValidBirthday
        case .chooseUsername:
            return !username.isEmpty
        default: return true
        }
    }
    
    
    func signOut() {
        DispatchQueue.main.async {
            self.isLoggedOut  = true
            self.name         = ""
            self.displayName  = ""
            self.phoneNumber  = ""
            self.countryCode  = ""
            self.code         = ""
            self.service.user = nil
            try? Auth.auth().signOut()
        }
    }
    
    
    func startPhoneVerification(completion: @escaping (Bool) -> Void) {
        showLoadingView()
        
        formatPhoneNumber { formattedPhoneNumber in
            self.verifyPhoneNumber(with: formattedPhoneNumber) { result in
                self.hideLoadingView()
                completion(result)
            }
        }
    }
}

// MARK: - Firebase Query Functions
extension AuthViewModel {
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
            self.universityId = ".com"
            completion(true)
        }
        
        COLLECTION_UNIVERSITIES.whereField("domain", isEqualTo: domain).getDocuments { snapshot, error in
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
    
    
    func register() {
        guard let image = image else { return }
        
        ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let user = User(dateJoined: Timestamp(),
                            name: self.name,
                            displayName: self.name,
                            username: self.username.lowercased(),
                            email: self.email.lowercased(),
                            profileImageUrl: imageUrl,
                            birthday: Timestamp(date: self.birthday),
                            universityId: self.universityId,
                            gender: self.gender,
                            accountType: .user,
                            bio: self.bio,
                            showAgeOnProfile: true)
            
            guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
            
            COLLECTION_USERS
                .document(uid)
                .setData(encodedUser) { _ in
                    self.service.fetchUser()
                }
        }
    }
}

// MARK: - Firebase Authentication Functions
extension AuthViewModel {
    private func verifyPhoneNumber(with phoneNumWithCode: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumWithCode, uiDelegate: nil) { verificationID, error in
            if let error = error as? NSError {
                self.handleAuthError(error)
                completion(false)
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            completion(true)
        }
    }
    
    
    private func verifyCode(completion: @escaping(Bool) -> Void) {
        showLoadingView()
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error as NSError? {
                self.handleAuthError(error)
                completion(false)
                return
            }
            
            guard let _ = result?.user else { return }
            self.service.fetchUser()
            self.hideLoadingView()
            completion(true)
        }
    }
    
    
    private func sendVerificationEmail() {
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
    
    
    func handleVerificationEmail(_ url: URL, completion: @escaping(Bool) -> Void) {
        showLoadingView()
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let linkParam = queryItems.first(where: { $0.name == "link" }),
              let linkString = linkParam.value,
              let linkUrl = URL(string: linkString),
              let linkQueryItems = URLComponents(url: linkUrl, resolvingAgainstBaseURL: true)?.queryItems,
              let continueUrl = linkQueryItems.first(where: { $0.name == "continueUrl" })?.value,
              let emailQueryItem = URLComponents(string: continueUrl)?.queryItems?.first(where: { $0.name == "email" }),
              emailQueryItem.value == email else {
            hideLoadingView()
            completion(false)
            return
        }
        
        let link = url.absoluteString
        let credential = EmailAuthProvider.credential(withEmail: email, link: link)
        
        Auth.auth().currentUser?.link(with: credential) { authResult, error in
            if let error = error {
                self.handleAuthError(error as NSError)
                completion(false)
                return
            }
            
            self.hideLoadingView()
            completion(true)
        }
    }
}

// MARK: - Helper Functions
extension AuthViewModel {
    private func hasShownOnboardingScreens() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasShownOnboardingScreens")
    }
    
    
    func next(_ state: Binding<AuthFlowViewState>) {
        let nextIndex = min(state.wrappedValue.rawValue + 1, AuthFlowViewState.allCases.last!.rawValue)
        
        if let nextState = AuthFlowViewState(rawValue: nextIndex) {
            state.wrappedValue = nextState
        }
    }
    
    
    func previous(_ state: Binding<AuthFlowViewState>) {
        let previousIndex = max(state.wrappedValue.rawValue - 1, AuthFlowViewState.allCases.first!.rawValue)
        
        if let previousState = AuthFlowViewState(rawValue: previousIndex) {
            state.wrappedValue = previousState
        }
    }
    
    
    private func formatPhoneNumber(completion: @escaping (String) -> Void) {
        var finalPhoneNumber = phoneNumber
        
        if phoneNumber.hasPrefix("+") {
            let detectedCountryCode = extractCountryCode(from: phoneNumber)
            
            if detectedCountryCode != countryCode {
                confirmationAlertItem = AlertContext.existingCountryCode(code: detectedCountryCode) {
                    // User wants to correct the phone number, so remove the detected country code and use the stored one
                    let correctedPhoneNumber = self.phoneNumber.replacingOccurrences(of: detectedCountryCode, with: "")
                    finalPhoneNumber = "\(self.countryCode)\(correctedPhoneNumber)"
                    completion(finalPhoneNumber)
                }
            } else {
                completion(finalPhoneNumber)
            }
        } else {
            finalPhoneNumber = "\(countryCode)\(phoneNumber)"
            completion(finalPhoneNumber)
        }
    }
    
    
    private func extractCountryCode(from phoneNumber: String) -> String {
        let pattern = #"^\+\d{1,3}"#
        
        if let range = phoneNumber.range(of: pattern, options: .regularExpression) {
            return String(phoneNumber[range])
        }
        
        return ""
    }
    
    
    private func convertStringToDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM  dd  yyyy"
        
        guard let date = dateFormatter.date(from: birthdayStr) else { return }
        if date < Date.now { birthday = date } else { return }
    }
    
    
    private func checkValidBirthday() {
        if birthdayStr.count > 12 {
            birthdayStr = String(birthdayStr.prefix(12))
        } else if birthdayStr.count < 12 {
            isValidBirthday = false
        } else {
            self.convertStringToDate()
        }
    }
    
    
    private func setOnboardingScreensShown(_ shown: Bool) {
        UserDefaults.standard.set(shown, forKey: "hasShownOnboardingScreens")
    }
    
    
    private func handleAuthError(_ error: NSError) {
        hideLoadingView()
        let errorCode = AuthErrorCode(_nsError: error)
        print("DEBUG: Auth Error: \(error.localizedDescription)")
        print("DEBUG: Auth Error: \(error)")
        
        switch errorCode.code {
        case .invalidCredential:
            alertItem = AlertContext.invalidCredential
        case .emailAlreadyInUse:
            alertItem = AlertContext.emailAlreadyInUse
        case .invalidEmail:
            alertItem = AlertContext.invalidEmail
        case .tooManyRequests:
            alertItem = AlertContext.tooManyRequests
        case .userNotFound:
            alertItem = AlertContext.userNotFound
        case .networkError:
            alertItem = AlertContext.networkError
        case .credentialAlreadyInUse:
            alertItem = AlertContext.credentialAlreadyInUse
        case .captchaCheckFailed:
            break
        default:
            alertItem = AlertContext.unspecifiedAuthError
            print("DEBUG: Unspecified Auth Error: \(error.localizedDescription)")
        }
    }
    
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
