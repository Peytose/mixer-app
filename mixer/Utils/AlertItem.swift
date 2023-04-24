//
//  AlertItem.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
    
    var alert: Alert {
        Alert(title: title, message: message, dismissButton: dismissButton)
    }
}

struct AlertItemTwo: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button
    
    var alert: Alert {
        Alert(title: title, message: message, primaryButton: primaryButton, secondaryButton: secondaryButton)
    }
}

struct AlertContext {
    //MARK: - Authentication Errors/Messages
    static let sentEmailLink                      = AlertItem(title: Text("Email Verification Link Sent"),
                                                              message: Text("Good news .. your email link was sent!\nFollow the instructions to confirm your email."),
                                                              dismissButton: .default(Text("Okie dokie")))
    
    static let unableToSendEmailLink              = AlertItem(title: Text("Authentication Error"),
                                                              message: Text("Unable to send link to verify email."),
                                                              dismissButton: .default(Text("That sucks.")))
    
    static let invalidCredential                  = AlertItem(title: Text(("Credential Error")),
                                                              message: Text("The supplied credential is invalid. It might be expired or malformed.\nPlease try again."),
                                                              dismissButton: .default(Text("Oops")))
    
    static let emailAlreadyInUse                  = AlertItem(title: Text(("Authentication Error")),
                                                              message: Text("This email is already in use by an existing account.\nSign in or enter a different email."),
                                                              dismissButton: .default(Text("Oops")))
    
    static let invalidEmail                       = AlertItem(title: Text(("Email Error")),
                                                              message: Text("The email you entered is badly formatted.\nPlease try again."),
                                                              dismissButton: .default(Text("Alright")))
    
    static let tooManyRequests                    = AlertItem(title: Text(("Authentication Error")),
                                                              message: Text("An abnormal number of requests have been made from this device to our Firebase Authentication servers.\nRetry again after some time."),
                                                              dismissButton: .default(Text("Weird")))
    
    static let userNotFound                       = AlertItem(title: Text(("Authentication Error")),
                                                              message: Text("We could not find any accounts matching the information you provided.\nConsider signing up instead."),
                                                              dismissButton: .default(Text("Okie dokie")))
    
    static let networkError                       = AlertItem(title: Text(("Network Error")),
                                                              message: Text("A network error occurred. Please try again."),
                                                              dismissButton: .default(Text("Oops")))
    
    static let credentialAlreadyInUse             = AlertItem(title: Text(("Credential Error")),
                                                              message: Text("This credential has already been linked with a different account.\nPlease try again."),
                                                              dismissButton: .default(Text("Oops")))
    
    static let unspecifiedAuthError               = AlertItem(title: Text(("Authentication Error")),
                                                              message: Text("You have encountered an error that is not defined natively.\nIf this persists, contact us. Otherwise, please try again."),
                                                              dismissButton: .default(Text("Hm ok")))
    
    static let reCAPTCHAChallenge                 = AlertItem(title: Text("Verification Required"),
                                                              message: Text("Please complete the reCAPTCHA challenge to verify your phone number."),
                                                              dismissButton: .default(Text("OK")))

    
    //MARK: - MapView Errors
    static let locationManagerFailed              = AlertItem(title: Text("Location Manager Error"),
                                                              message: Text("The location manager did fail with error.\nPlease try again later."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let unableToGetMapItems                = AlertItem(title: Text("Map Error"),
                                                              message: Text("Unable to get map items.\nPlease try again later."),
                                                              dismissButton: .default(Text("Ok")))
    
    //MARK: - CreateEvent Errors/Messages
    static let eventVisiblityInfo                 = AlertItem(title: Text("Event Visibility"),
                                                              message: Text("Public events are visible to all users. Private events are only visible to invited users and users on the guest list."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let invitePreferrenceInfo              = AlertItem(title: Text("Event Exclusivity"),
                                                              message: Text("Anyone can be checked into and see an open event's details. Only invited individuals can be checked into and see an invite only event's details."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let checkInMethodInfo                  = AlertItem(title: Text("Check-in Method"),
                                                              message: Text("Manual check-in allows you to handle check-in however you want. QR Code check-in allows you to quickly scan guests in and check if they are on the guest list."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let guestlistInfo                      = AlertItem(title: Text("Use guestlist?"),
                                                              message: Text("The guest list features allows you to quickly."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let guestLimitInfo                     = AlertItem(title: Text("Set guest limit"),
                                                              message: Text("N/A"),
                                                              dismissButton: .default(Text("Ok")))
    
    static let memberInviteLimitInfo              = AlertItem(title: Text("Set member invite limit"),
                                                              message: Text("N/A"),
                                                              dismissButton: .default(Text("Ok")))
    
    static let guestInviteLimitInfo               = AlertItem(title: Text("Set guest invite limit"),
                                                              message: Text("N/A"),
                                                              dismissButton: .default(Text("Ok")))
    
    static let manuallyApproveInfo                = AlertItem(title: Text("Manually approve guests"),
                                                              message: Text("N/A"),
                                                              dismissButton: .default(Text("Ok")))
    
    static let preEnableWaitlistInfo              = AlertItem(title: Text("Pre-enable waitlist"),
                                                              message: Text("N/A"),
                                                              dismissButton: .default(Text("Ok")))
    
    static let registrationCutoffInfo             = AlertItem(title: Text("Registration cutoff"),
                                                              message: Text("N/A"),
                                                              dismissButton: .default(Text("Ok")))
    
    //MARK: - LocationListView Errors
    static let unableToGetAllCheckedInProfiles    = AlertItem(title: Text("Server"),
                                                              message: Text("We are unable get users checked in at this time.\nPlease try again."),
                                                              dismissButton: .default(Text("Ok")))
    
    //MARK: - ProfileView Errors
    static let invalidProfile                     = AlertItem(title: Text("Invalid Profile"),
                                                              message: Text("All fields are required as well as a profile photo. Your bio must be < 100 characters.\nPlease try again."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let noUserRecord                       = AlertItem(title: Text("No User Record"),
                                                              message: Text("You must log into iCloud on your phone in order to utilize Dub Dub Grub's Profile. Please log in on your phone's settings screen."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let createProfileSuccess               = AlertItem(title: Text("Profile Created Successfully!"),
                                                              message: Text("Your profile has successfully been created."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let createProfileFailure               = AlertItem(title: Text("Failed to Create Profile"),
                                                              message: Text("We were unable to create your profile at this time.\nPlease try again later or contact customer support if this persists."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let unableToGetProfile                 = AlertItem(title: Text("Unable to Retrieve Profile"),
                                                              message: Text("We were unable to retrieve your profile at this time. Please check your internet connection and try again later or contact customer support if this persists."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let updateProfileSuccess               = AlertItem(title: Text("Profile Update Success!"),
                                                              message: Text("Your Dub Dub Grub profile was updated successfully."),
                                                              dismissButton: .default(Text("Sweet!")))
    
    static let updateProfileFailure               = AlertItem(title: Text("Profile Update Failed"),
                                                              message: Text("We were unable to update your profile at this time.\nPlease try again later."),
                                                              dismissButton: .default(Text("Shucks!")))
    
    //MARK: - LocationDetailView Errors
    static let invalidPhoneNumber                 = AlertItem(title: Text("Invalid Phone Number"),
                                                              message: Text("The phone number for the location is invalid. Please look up the phone number yourself."),
                                                              dismissButton: .default(Text("Shucks!")))
    
    static let unableToGetCheckInStatus           = AlertItem(title: Text("Server Error"),
                                                              message: Text("Unable to retrieve checked in status of the current user.\nPlease try again."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let unableToCheckInOrOut               = AlertItem(title: Text("Server Error"),
                                                              message: Text("We are unable to check in/out at this time.\nPlease try again."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let unableToGetCheckedInProfiles       = AlertItem(title: Text("Server Error"),
                                                              message: Text("We are unable get users checked into this location at this time.\nPlease try again."),
                                                              dismissButton: .default(Text("Ok")))
    
    //MARK: - Guestlist Errors/Messages
    static func guestAlreadyCheckedIn(confirmAction: @escaping () -> Void) -> AlertItemTwo {
        AlertItemTwo(title: Text("Remove guest?"),
                     message: Text("The guest you are trying to remove has already checked in to the event. Are you sure you meant to remove them?"),
                     primaryButton: .default(Text("Remove").bold(),
                                             action: confirmAction),
                     secondaryButton: .default(Text("Oops nvm")))
    }
    
    //MARK: - ProfileSettings Errors/Messages
    static func confirmChangesToProfile(confirmAction: @escaping () -> Void) -> AlertItemTwo {
        AlertItemTwo(title: Text("Comfirm changes"),
                     message: Text("It seems that you've changed details about your profile. Apply these changes?"),
                     primaryButton: .default(Text("Yes!").bold(),
                                             action: confirmAction),
                     secondaryButton: .default(Text("Oops nvm")))
    }
}
