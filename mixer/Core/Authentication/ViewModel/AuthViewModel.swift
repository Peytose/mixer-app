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
import FirebaseFirestore
import Combine

enum AuthFlowViewState: Int, CaseIterable {
    case enterName
    case enterPhone
    case verifyCode
    case uploadProfilePicAndBio
    case enterBirthdayAndUniversity
    case selectGender
    case chooseUsername
}

class AuthViewModel: ObservableObject {
    // User-Related Variables
    @Published var firstName       = ""
    @Published var lastName        = ""
    @Published var phoneNumber     = ""
    @Published var countryCode     = ""
    @Published var code            = ""
    @Published var image: UIImage?
    @Published var bio             = ""
    @Published var birthdayStr     = "" { didSet { checkValidBirthday() } }
    @Published var birthday        = Date.now { didSet { isBirthdayValid = true } }
    @Published var gender          = Gender.woman
    @Published var username        = "" {
        didSet {
            checkUsernameValidity()
        }
    }
    @Published var universityId    = ""
    @Published var universityName  = ""
    @Published var isBirthdayValid = false
    @Published var isUsernameValid = false
    
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
    private let algoliaManager = AlgoliaManager.shared
    private let service        = UserService.shared
    static let shared          = AuthViewModel()
    
    
    init() {
        DispatchQueue.main.async {
            self.isOnboardingScreensVisible = !self.hasShownOnboardingScreens()
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
            case .uploadProfilePicAndBio: return AnyView(EnterProfilePictureAndBioView())
            case .enterBirthdayAndUniversity: return AnyView(EnterBirthdayAndUniversityView())
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
        case .uploadProfilePicAndBio, .enterBirthdayAndUniversity, .selectGender:
            self.next(state)
        case .chooseUsername:
            self.register()
        }
    }
    
    
    func buttonText(for state: AuthFlowViewState) -> String {
        switch state {
            case .chooseUsername: return "Join mixer!"
            default: return "Continue"
        }
    }
    
    
    func buttonMessage(for state: AuthFlowViewState) -> String? {
        if isButtonActiveForState(state) {
            return nil
        }
        
        switch state {
        case .enterName: return "Please enter your name"
            case .enterPhone: return "Please enter a valid phone number"
            case .enterBirthdayAndUniversity: return "Please enter a valid date and/or select a university"
            case .chooseUsername: return "Please enter a unique username"
            default: return nil
        }
    }
    
    
    func isButtonActiveForState(_ state: AuthFlowViewState) -> Bool {
        switch state {
        case .enterName:
            return !firstName.isEmpty && !lastName.isEmpty
        case .enterPhone:
            return !phoneNumber.isEmpty
        case .verifyCode:
            return !code.isEmpty
        case .uploadProfilePicAndBio:
            return image != nil
        case .enterBirthdayAndUniversity:
            return isBirthdayValid && !universityId.isEmpty
        case .chooseUsername:
            return !username.isEmpty && self.isUsernameValid
        default: return true
        }
    }
    
    
    func signOut() {
        DispatchQueue.main.async {
            self.isLoggedOut  = true
            self.firstName    = ""
            self.lastName     = ""
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
    
    
    func selectUniversity(_ university: University) {
        guard let id = university.id else { return }
        self.universityId   = id
        self.universityName = university.shortName ?? university.name
    }
}

// MARK: - Firebase Query Functions
extension AuthViewModel {
    func register() {
        guard let image = image, let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
            let user = User(dateJoined: Timestamp(),
                            firstName: self.firstName.trimSpaceAndCapitalize,
                            lastName: self.lastName.trimSpaceAndCapitalize,
                            displayName: self.firstName.trimSpaceAndCapitalize,
                            username: self.username.removedSpecialCharacters.lowercased(),
                            profileImageUrl: imageUrl,
                            birthday: Timestamp(date: self.birthday),
                            universityId: self.universityId,
                            gender: self.gender,
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
    
    
    private func checkUsernameValidity() {
        let usernamePattern = "^[a-zA-Z0-9_]{4,}$" // Adjust pattern as needed
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernamePattern)
        
        guard usernamePredicate.evaluate(with: self.username) else {
            self.isUsernameValid = false
            return
        }
        
        AlgoliaManager.shared.validateUsername(self.username) { isValid in
            DispatchQueue.main.async {
                self.isUsernameValid = isValid
            }
        }
    }
    
    
    private func checkValidBirthday() {
        if birthdayStr.count > 12 {
            birthdayStr = String(birthdayStr.prefix(12))
        } else if birthdayStr.count < 12 {
            isBirthdayValid = false
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
        
        switch errorCode.code {
        case .invalidCredential:
            alertItem = AlertContext.invalidCredential
        case .tooManyRequests:
            alertItem = AlertContext.tooManyRequests
        case .userNotFound:
            alertItem = AlertContext.userNotFoundAuth
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
