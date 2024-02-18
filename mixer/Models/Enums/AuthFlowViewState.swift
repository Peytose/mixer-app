//
//  AuthFlowViewState.swift
//  mixer
//
//  Created by Peyton Lyons on 8/8/23.
//

import Foundation

enum AuthFlowViewState: Int, CaseIterable {
    case enterName
    case enterPhone
    case verifyCode
    case uploadProfilePicAndBio
    case enterBirthdayAndUniversity
    case selectGender
    case chooseUsername
    
    var buttonText: String {
        switch self {
            case .chooseUsername: return "Join mixer!"
            default: return "Continue"
        }
    }
    
    var buttonMessage: String? {
        switch self {
            case .enterName: return "Please enter your name"
            case .enterPhone: return "Please enter a valid phone number"
            case .enterBirthdayAndUniversity: return "Please enter a valid date and/or select a university"
            case .chooseUsername: return "Please enter a unique username"
            default: return nil
        }
    }
}
