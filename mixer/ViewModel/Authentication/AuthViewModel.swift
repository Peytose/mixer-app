//
//  AuthViewModel.swift
//  InstagramClone
//
//  Created by Peyton Lyons on 11/8/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: CachedUser?
    @Published var emailIsVerified           = false
    @Published var showAuthFlow              = false
    @Published var name                      = ""
    @Published var email                     = ""
    @Published var emailCode                 = ""
    @Published var universityData            = [String: String]()
    @Published var phoneNumber               = ""
    @Published var countryCode               = ""
    @Published var code                      = ""
    @Published var image: UIImage?
    @Published var bio                       = ""
    @Published var birthdayString            = "" { didSet { checkValidBirthday() } }
    @Published var birthday                  = Date.now { didSet { isValidBirthday = true } }
    @Published var gender                    = "Female"
    @Published var isGenderPublic            = true
    @Published var username                  = ""
    @Published var isValidBirthday           = false
    @Published var didSendResentPasswordLink = false
    @Published var active                    = Screen.allCases.first!
    @Published var alertItem: AlertItem?
    @Published var isLoading: Bool = false
    var hosts = [CachedHost]()
    
    static let shared = AuthViewModel()
    
    enum Screen: Int, CaseIterable {
        case name
        case phone
        case code
        case email
        case picAndBio
        case birthday
        case gender
        case username
    }
    
    init() {
        self.isLoading = true
        userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    
    func next() {
        let nextScreenIndex = min(active.rawValue + 1, Screen.allCases.last!.rawValue)
        if let screen = Screen(rawValue: nextScreenIndex) { active = screen }
    }
    
    
    func previous() {
        let previousScreenIndex = max(active.rawValue - 1, Screen.allCases.first!.rawValue)
        if let screen = Screen(rawValue: previousScreenIndex) { active = screen }
    }
    
    
    func signOut() {
        DispatchQueue.main.async {
            self.active      = Screen.allCases.first!
            self.name        = ""
            self.phoneNumber = ""
            self.countryCode = ""
            self.code        = ""
            self.userSession = nil
            self.currentUser = nil
            try? Auth.auth().signOut()
        }
    }
    
    
    func resetPassword(withEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("DEBUG: Failed to send link with error \(error.localizedDescription)")
                return
            }
            
            self.didSendResentPasswordLink = true
        }
    }
    
    
    func fetchUser() {
        self.isLoading = true
        
        guard let uid = userSession?.uid else {
            print("DEBUG: couldn't get uid")
            self.isLoading = false
            return
        }
        
        print("DEBUG: successfully fetched uid. \(uid)")
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else {
                print("DEBUG: Error getting user. \(String(describing: snapshot))")
                self.isLoading = false
                return
            }
            
            let cachedUser = CachedUser(from: user)
            self.currentUser = cachedUser
            print("DEBUG: Current user: \(String(describing: self.currentUser))")
            
            if let hostPrivileges = cachedUser.hostPrivileges {
                for key in hostPrivileges.keys {
                    print("DEBUG: key for host privileges: \(key)")
                    self.fetchHost(uid: key)
                }
                
                self.currentUser?.isHost = true
                
                do {
                    try UserCache.shared.cacheUser(cachedUser)
                } catch {
                    print("DEBUG: Error caching user after verifying host privileges. \(error.localizedDescription)")
                }
            }
        }
        
        self.isLoading = false
    }
    
    
    private func fetchHost(uid: String) {
        COLLECTION_HOSTS.document(uid).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Error fetching host. \(error.localizedDescription)")
                return
            }
            
            guard let host = try? snapshot?.data(as: Host.self) else { return }
            self.hosts.append(CachedHost(from: host))
            print("DEBUG: Host fetched from user: \(self.hosts)")
        }
    }
    
    
    func sendEmailLink() {
        print("DEBUG: BUTTON PRESSED ✅")
        
        // Create action code settings object
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://mixer.page.link/email-login?email=\(email)")
        actionCodeSettings.handleCodeInApp = true
        // Send email link with Firebase Auth
        Auth.auth().sendSignInLink(toEmail: self.email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error as? NSError {
                self.handleAuthError(error)
                print("DEBUG: Error sending email link. \(error.localizedDescription)")
                return
            }
            
            print("DEBUG: Sent email to \(self.email). ✅")
            self.alertItem = AlertContext.sentEmailLink
        }
    }
    
    
    func handleEmailLink(_ url: URL) {
        print("DEBUG: Got email link. \(url)")
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems {
            // Extract the "link" parameter from the query items
            if let linkParam = queryItems.first(where: { $0.name == "link" }),
               let linkString = linkParam.value,
               let linkUrl = URL(string: linkString),
               let linkQueryItems = URLComponents(url: linkUrl, resolvingAgainstBaseURL: true)?.queryItems {
                let continueUrlQueryItem = linkQueryItems.first(where: { $0.name == "continueUrl" })
                let continueUrl = continueUrlQueryItem?.value
                
                if let continueUrl = continueUrl,
                   let continueUrlComponents = URLComponents(string: continueUrl),
                   let continueUrlQueryItems = continueUrlComponents.queryItems {
                    
                    // Extract the email parameter
                    let emailQueryItem = continueUrlQueryItems.first(where: { $0.name == "email" })
                    if emailQueryItem?.value == email {
                        print("DEBUG: email from link. \(email)")
                        let link = url.absoluteString
                        
                        let credential = EmailAuthProvider.credential(withEmail: email, link: link)
                        
                        guard let user = userSession else { return }
                        user.link(with: credential) { authResult, error in
                            if let error = error {
                                self.handleAuthError(error as NSError)
                                print("DEBUG: Error linking email. \(error.localizedDescription)")
                                return
                            }
                            
                            guard let user = authResult?.user else { return }
                            self.userSession = user
                            self.next()
                        }
                    }
                }
            }
        }
    }
    
    
    func sendPhoneVerification() {
        let phoneNumWithCode = "\(countryCode)\(phoneNumber)"
        print("DEBUG: phone number with country code. \(phoneNumWithCode)")
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumWithCode, uiDelegate: nil) { verificationID, error in
            if let error = error as? NSError {
                self.handleAuthError(error)
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.next()
        }
    }
    
    
    func verifyPhoneNumber() {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)

        Auth.auth().signIn(with: credential) { result, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.captchaCheckFailed.rawValue {
                    // If reCAPTCHA verification is required, present the reCAPTCHA challenge to the user
                    PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumber, uiDelegate: nil) { verificationID, error in
                        if let error = error as NSError? {
                            self.handleAuthError(error)
                        } else {
                            // Store the new verification ID and present the reCAPTCHA challenge
                            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                            self.alertItem = AlertContext.reCAPTCHAChallenge
                        }
                    }
                } else {
                    self.handleAuthError(error)
                }
            } else {
                guard let user = result?.user else { return }
                self.userSession = user
                print("Successfully verified phone number!")
                self.fetchUser()
                self.next()
            }
        }
    }
    
    
    func register() {
        print("DEBUG: Register button tapped!")
        guard let image = image else {
            print("DEBUG: image not found.")
            return
        }
        
        print("DEBUG: Image found.")
        
        ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
            guard let uid = self.userSession?.uid else {
                print("DEBUG: couldn't get userSession uid.")
                return
            }
            print("DEBUG: ✅ Successfully registered user ... ")
            
            let data = ["name": self.name,
                        "email": self.email.lowercased(),
                        "profileImageUrl": imageUrl,
                        "bio": self.bio,
                        "username": self.username.lowercased(),
                        "birthday": Timestamp(date: self.birthday),
                        "gender": self.gender,
                        "universityData": self.universityData,
                        "userOptions": [UserOption.showAgeOnProfile.rawValue: true],
                        "uid": uid,
                        "dateJoined": Timestamp()] as [String : Any]
            
            COLLECTION_USERS.document(uid).setData(data) { _ in
                print("DEBUG: ✅ Succesfully uploaded user data ...")
                self.fetchUser()
            }
        }
    }
    
    
    func updateCurrentUser(user: CachedUser) {
        self.currentUser = user
        print("DEBUG: Current user updated.")
    }
    
    
    private func fetchUniversity(completion: @escaping (Bool) -> Void) {
        if email.isValidEmail {
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

            if let universityName = document["name"] as? String, let universityUID = document.documentID as String? {
                self.universityData = ["name": universityName,
                                       "uid": universityUID]
                // Save the universityData dictionary to the user document
                completion(true)
                return
            }

            completion(false)
        }
    }
    
    
    private func convertStringToDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM  dd  yyyy"
        
        let date = dateFormatter.date(from: birthdayString)!
        
        print("DEBUG: birthday is \(date)")
        
        if date < Date.now { birthday = date } else { return }
    }
    
    
    private func checkValidBirthday() {
        if birthdayString.count > 12 { birthdayString = String(birthdayString.prefix(12)) }
        else if birthdayString.count < 12 { isValidBirthday = false }
        else { convertStringToDate() }
    }
    
    
    private func handleAuthError(_ error: NSError) {
        let errorCode = AuthErrorCode(_nsError: error)
        
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
            //        case .requiresRecentLogin:
            //        case .invalidUserToken:
        case .networkError:
            alertItem = AlertContext.networkError
        case .credentialAlreadyInUse:
            alertItem = AlertContext.credentialAlreadyInUse
            //        case .unauthorizedDomain:
            //        case .adminRestrictedOperation:
            //        case .emailChangeNeedsVerification:
        default:
            alertItem = AlertContext.unspecifiedAuthError
            print("DEBUG: Auth error \(error.localizedDescription)")
        }
    }
}
