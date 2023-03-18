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
    @Published var currentUser: User?
    @Published var emailIsVerified           = false
    @Published var name                      = ""
    @Published var email                     = ""
    @Published var emailCode                 = ""
    @Published var university                = ""
    @Published var phoneNumber               = ""
    @Published var countryCode               = ""
    @Published var code                      = ""
    @Published var image: UIImage?
    @Published var bio                       = ""
    @Published var birthdayString            = "" { didSet { checkValidBirthday() } }
    @Published var birthday                  = Date.now { didSet { isValidBirthday = true } }
    @Published var gender                    = "Female"
    @Published var username                  = ""
    @Published var isValidBirthday           = false
    @Published var didSendResentPasswordLink = false
    @Published var active                    = Screen.allCases.first!
    //    @Published var hasError                  = false
    @Published var alertItem: AlertItem?
    var hosts = [Host?]()
    
    static let shared = AuthViewModel()
    
    enum Screen: Int, CaseIterable {
        case name
        case phone
        case code
        case email
        case picAndBio
        case personal
        case username
    }
    
    init() {
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
    
    
    //    func login(withEmail email: String, password: String) {
    //        Auth.auth().signIn(withEmail: email, password: password) { result, error in
    //            if let error = error {
    //                print("DEBUG: Login failed \(error.localizedDescription)")
    //                return
    //            }
    //
    //            guard let user = result?.user else { return }
    //            self.userSession = user
    //            self.fetchUser()
    //        }
    //    }
    
    
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
        guard let uid = userSession?.uid else {
            print("DEBUG: couldn't get uid")
            return
        }
        
        print("DEBUG: \(uid)")
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else {
                print("DEBUG: Error getting user")
                print(String(describing: snapshot?.data()))
                return
            }
            self.currentUser = user
            
            guard let isHost = user.isHost else { return }
            if isHost { self.fetchHost(uid: uid) } else { return }
        }
    }
    
    
    private func fetchHost(uid: String) {
        COLLECTION_HOSTS.whereField("ownerUuid", isEqualTo: uid).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            self.hosts = documents.compactMap({ try? $0.data(as: Host.self) })
        }
    }
    
    
    func sendEmailLink() {
        print("DEBUG: BUTTON PRESSED ✅")
        if !email.hasSuffix(".edu") { return } // make sure email ends in .edu (temp solution)
        
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
                            print("DEBUG: Sucessfully linked email! Moving to next screen ...")
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
            if let error = error as? NSError {
                self.handleAuthError(error)
                return
            }
            
            guard let user = result?.user else { return }
            self.userSession = user
            print("Successfully verified phone number!")
            self.fetchUser()
            self.next()
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
                        "university": self.university,
                        "uid": uid,
                        "dateJoined": Timestamp()]
            
            COLLECTION_USERS.document(uid).setData(data) { _ in
                print("DEBUG: ✅ Succesfully uploaded user data ...")
                self.fetchUser()
            }
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
