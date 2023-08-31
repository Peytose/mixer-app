//
//  CheckInMethod.swift
//  mixer
//
//  Created by Peyton Lyons on 8/30/23.
//

import SwiftUI

enum CheckInMethod: String, Codable, CaseIterable, IconRepresentable {
    case qrCode   = "QR Code"
    case manual   = "Manual"
    case outOfApp = "Out-of-app"
    
    var icon: String {
        switch self {
        case .qrCode: return "qrcode"
        case .manual: return "pencil.line"
        case .outOfApp: return ""
        }
    }
    
    var description: String {
        switch self {
        case .qrCode:
            return "Guests can use the app to scan a QR code at the event to check in quickly and easily."
        case .manual:
            return "Hosts can manually check in guests by entering their information into a form within the app. This option is useful for guests who don't have the app or can't scan a QR code."
        case .outOfApp:
            return "Hosts can handle check-in outside the app. This option is useful if hosts are using a third-party check-in system or if they prefer to handle check-in manually outside the app."
        }
    }
}
