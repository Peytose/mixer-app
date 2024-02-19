//
//  AlertItem.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

enum AlertType: Identifiable {
    case regular(AlertItem?)
    case confirmation(ConfirmationAlertItem?)
    
    var id: Int {
        switch self {
        case .regular: return 1
        case .confirmation: return 2
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
    
    var alert: Alert {
        Alert(title: title, message: message, dismissButton: dismissButton)
    }
}

struct ConfirmationAlertItem: Identifiable {
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
    // MARK: - ManageMembersViewModel Errors/Messages
    static let cannotInviteSelf               = AlertItem(title: Text("Error"),
                                                          message: Text("You are already apart of this organization."),
                                                          dismissButton: .default(Text("Ok")))
    
    static let duplicateMemberInvite          = AlertItem(title: Text("Duplicate Invite"),
                                                          message: Text("This user has already been invited."),
                                                          dismissButton: .default(Text("Ok")))
    
    static let memberAlreadyJoined            = AlertItem(title: Text("Cannot Invite User"),
                                                          message: Text("This user is already a member."),
                                                          dismissButton: .default(Text("Ok")))
    
    static func confirmRemoveMember(confirmAction: @escaping () -> Void) -> ConfirmationAlertItem {
        ConfirmationAlertItem(title: Text("Confirmation Required"),
                     message: Text("Are you sure you want to remove this member?"),
                     primaryButton: .default(Text("Remove").bold(), action: confirmAction),
                     secondaryButton: .default(Text("Oops nvm")))
    }
    
    static let unableToRemoveMember               = AlertItem(title: Text("Error"),
                                                              message: Text("We were unable to remove this member.\nPlease try again."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let unableToGetUserFromUsername        = AlertItem(title: Text("Unable to Find User"),
                                                              message: Text("We were unable to find a user from this username.\nPlease try again."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let unableToAddMember                  = AlertItem(title: Text("Failed to Add Member"),
                                                              message: Text("We were unable to add a member at this time.\nPlease try again later. If this persists, go to Profile > Settings > Feedback & Support > Report a Bug."),
                                                              dismissButton: .default(Text("Ok")))
    
    
    // MARK: - EventDetailView Messages
    static let locationDetailsInfo                = AlertItem(title: Text("Location Details"),
                                                              message: Text("For invite only parties that you have not been invited, you can only see the general location. Once you are on the guest list, you will be able to see the exact location"),
                                                              dismissButton: .default(Text("Got it!")))
    
    static let wetAndDryEventsInfo                = AlertItem(title: Text("Wet and Dry Events"),
                                                              message: Text("Wet events offer beer/alcohol. Dry events do not offer alcohol."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let openAndInviteOnlyEventsInfo        = AlertItem(title: Text("Open and Invite Only Events"),
                                                              message: Text("You can only see the exact location and start time of an Invite Only Event if you are on its guestlist. On the other hand, you can always see all the details of an Open Event"), dismissButton: .default(Text("Ok")))
    
    
    //MARK: - Authentication Errors/Messages
    static func existingCountryCode(code: String, denyAction: @escaping () -> Void) -> ConfirmationAlertItem {
        ConfirmationAlertItem(title: Text("Confirm Phone Number"),
                              message: Text("We detected the country code \(code) in your phone number. Is this correct?"),
                              primaryButton: .default(Text("Yes").bold()),
                              secondaryButton: .default(Text("Nope"), action: denyAction))
    }
    
    static let sentEmailLink                      = AlertItem(title: Text("Email Verification Link Sent"),
                                                              message: Text("Good news .. your email link was sent!\nFollow the instructions to confirm your email."),
                                                              dismissButton: .default(Text("Okie dokie")))
    
    static let unableToSendEmailLink              = AlertItem(title: Text("Authentication Error"),
                                                              message: Text("Unable to send link to verify email. It could be that your school is not in our records.\nContact us at www.partywithmixer.com/helppage"),
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
    
    static let unableToGetGuestlistEvents         = AlertItem(title: Text("Error"),
                                                              message: Text("Unable to get host events.\nPlease try again later."),
                                                              dismissButton: .default(Text("Ok")))
    
    
    //MARK: - EventFlow Errors/Messages
    static let alcoholInfo                        = AlertItem(title: Text("Event Alcohol Status"),
                                                              message: Text("Wet events contain alcohol, while dry events don't. This allows guests to know what to expect."),
                                                              dismissButton: .default(Text("Ok")))
    
    
    static let aboutAmenitiesInfo                 = AlertItem(title: Text("What are 'Amenities'?"),
                                                              message: Text("Let your guests know what to expect before coming to your event. List important amenities like bathrooms, DJ, beer, water, etc..."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let eventVisiblityInfo                 = AlertItem(title: Text("Event Visibility"),
                                                              message: Text("Public events are visible to all users. Private events are only visible to invited users and users on the guest list."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let invitePreferrenceInfo              = AlertItem(title: Text("Event Exclusivity"),
                                                              message: Text("Anyone can be checked into and see an open event's details. Only invited individuals can be checked into and see an invite only event's details."),
                                                              dismissButton: .default(Text("Ok")))
    
    static let checkInMethodInfo                  = AlertItem(title: Text("Check-in Method"),
                                                              message: Text("Check-in via mixer allows you to handle check-in manually in the app through swipe actions or buttons. It also enabled you to use QR codes to quickly scan guests as well as check if they are on the guestlist.\nHowever, if you want to handle check-in on your own, choose 'Out-of-app'"),
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
    
    
    //MARK: - ProfileView Messages/Errors
    static func confirmBlock(name: String, confirmAction: @escaping () -> Void) -> ConfirmationAlertItem {
        ConfirmationAlertItem(title: Text("Block \(name)?"),
                     message: Text("\(name) will no longer be able to see your profile, activity, or follow you."),
                     primaryButton: .default(Text("Block").bold(), action: confirmAction),
                     secondaryButton: .default(Text("Cancel")))
    }
    
    static func confirmRemoveFriend(confirmAction: @escaping () -> Void) -> ConfirmationAlertItem {
        ConfirmationAlertItem(title: Text("Confirmation Required"),
                     message: Text("Are you sure you want unadd this person as a friend?\nYou will have to request again."),
                     primaryButton: .default(Text("Unadd").bold(), action: confirmAction),
                     secondaryButton: .default(Text("Go back")))
    }
    
    static let invalidProfile                     = AlertItem(title: Text("Invalid Profile"),
                                                              message: Text("All fields are required as well as a profile photo. Your bio must be < 100 characters.\nPlease try again."),
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
    
    static let updateProfileFailure               = AlertItem(title: Text("Profile Update Failed"),
                                                              message: Text("We were unable to update your profile at this time.\nPlease try again later."),
                                                              dismissButton: .default(Text("Shucks!")))
    
    static let accountDeletionFailedDueToHosting  = AlertItem(title: Text("Account Deletion Failed"),
                                                              message: Text("You are currently the main user for one or more hosts. Please transfer your hosting privileges to another member in Host Dashboard > Members before deleting your account."),
                                                              dismissButton: .default(Text("Got it!")))
    
    static let accountDeletionGeneralError        = AlertItem(title: Text("Account Deletion Failed"),
                                                              message: Text("We encountered an issue deleting your account. Please contact us immediately at Profile > Settings > Questions for assistance."),
                                                              dismissButton: .default(Text("Got it!")))

    
    //MARK: - LocationDetailView Errors
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
    static let genderRatioInfo                    = AlertItem(title: Text("Ratio Explanation"),
                                                              message: Text("This ratio represents the number of males to females in the guest list."),
                                                              dismissButton: .default(Text("Got it")))
    
    static let duplicateGuestInvite               = AlertItem(title: Text("Duplicate Invite"),
                                                              message: Text("This user has already been invited."),
                                                              dismissButton: .default(Text("Ok")))
                                                              
                                                              
    static let guestAlreadyJoined                 = AlertItem(title: Text("Cannot Re-invite User"),
                                                              message: Text("This user has already checked in!"),
                                                              dismissButton: .default(Text("Ok")))
    
    
    static let unableToAddGuest                   = AlertItem(title: Text("Failed to Add Guest"),
                                                              message: Text("We were unable to add the guest at this time.\nPlease try again later. If this persists, go to Profile > Settings > Feedback & Support > Report a Bug."),
                                                              dismissButton: .default(Text("Ok")))
    
    
    static func guestAlreadyCheckedIn(confirmAction: @escaping () -> Void) -> ConfirmationAlertItem {
        ConfirmationAlertItem(title: Text("Remove guest?"),
                     message: Text("The guest you are trying to remove has already checked in to the event. Are you sure you meant to remove them?"),
                     primaryButton: .default(Text("Remove").bold(),
                                             action: confirmAction),
                     secondaryButton: .default(Text("Oops nvm")))
    }
    
    
    //MARK: - ProfileSettings Errors/Messages
    static func confirmChangesToProfile(confirmAction: @escaping () -> Void) -> ConfirmationAlertItem {
        ConfirmationAlertItem(title: Text("Comfirm changes"),
                     message: Text("It seems that you've changed details about your profile. Apply these changes?"),
                     primaryButton: .default(Text("Yes!").bold(),
                                             action: confirmAction),
                     secondaryButton: .default(Text("Oops nvm")))
    }
}
