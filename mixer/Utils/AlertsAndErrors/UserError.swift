//
//  UserError.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/24.
//

import Foundation

enum UserError: CustomError {
    case cannotInviteSelf
    case unauthorized
    case userNotFound
    // Add more cases as needed
    
    var alertItem: AlertItem {
        switch self {
        case .cannotInviteSelf:
            return AlertContext.cannotInviteSelf
        case .unauthorized:
            return AlertContext.unauthorized
        case .userNotFound:
            return AlertContext.userNotFound
        // Handle other cases accordingly
        }
    }
}
