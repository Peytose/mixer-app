//
//  Color+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

extension Color {
     
    // MARK: - Text Colors
    static let lightText = Color(UIColor.lightText)
    static let darkText = Color(UIColor.darkText)
    static let placeholderText = Color(UIColor.placeholderText)

    // MARK: - Label Colors
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)
    
    // MARK: - Background Colors
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    
    static let SlightlyDarkerBlueBackground = Color(red: 8/255, green: 8/255, blue: 10/255)
    static let SlightlyBlueBackground = Color(red: 10/255, green: 10/255, blue: 12/255)
    static let SpotifyDarkGray = Color(red: 18/255, green: 18/255, blue: 18/255)


    // MARK: - Fill Colors
    static let systemFill = Color(UIColor.systemFill)
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
    
    // MARK: - Grouped Background Colors
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
    
    // MARK: - Gray Colors
    static let systemGray = Color(UIColor.systemGray)
    static let systemGray2 = Color(UIColor.systemGray2)
    static let systemGray3 = Color(UIColor.systemGray3)
    static let systemGray4 = Color(UIColor.systemGray4)
    static let systemGray5 = Color(UIColor.systemGray5)
    static let systemGray6 = Color(UIColor.systemGray6)
    
    // MARK: - Other Colors
    static let separator = Color(UIColor.separator)
    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    static let link = Color(UIColor.link)
    
    static let DesignCodeWhite = Color(red: 242/255, green: 246/255, blue: 255/255)
    static let Offwhite2 = Color(red: 245/255, green: 246/255, blue: 250/255)
    static let QRCodeBackground = Color(red: 15/255, green: 18/255, blue: 28/255)

    //MARK: - Chosen Gradients
    static let mixerPurpleGradient = LinearGradient(gradient: Gradient(colors: [Color.gradientPurple1, Color.gradientPurple2]), startPoint: .top, endPoint: .bottom)
//    static let mixerPurpleGradient2 = LinearGradient(gradient: Gradient(colors: [Color.mixerIndigo, Color.mixerPurple]), startPoint: .top, endPoint: .bottom)
    static let profileGradient = LinearGradient(gradient: Gradient(stops: [.init(color: Color.mixerBackground, location: 0), .init(color: .clear, location: 1)]), startPoint:.top, endPoint: .bottom)
    
    static let gradientPurple1 = Color(red: 112/255, green: 63/255, blue: 213/255)
    static let gradientPurple2 = Color(red: 76/255, green: 20/255, blue: 178/255)
    
    //MARK: Chosen Colors
    static let mixerPurple = Color(red: 90/255, green: 60/255, blue: 196/255) //MARK: The main purple we are using (its more of an indigo)
    static let mixerIndigo = Color(red: 124/255, green: 65/255, blue: 254/255) //MARK: The main purple we are using (its more of an indigo)
    static let mixerBlue = Color(red: 25/255, green: 99/255, blue: 221/255) //MARK: The main purple we are using (its more of an indigo)
    
    //MARK: Chosen Background Colors
    static let mixerBackground = Color(red: 15/255, green: 14/255, blue: 18/255)
//    static let mixerBackground = Color(red: 0/255, green: 0/255, blue: 0/255)
    static let mixerSecondaryBackground = Color(red: 28/255, green: 27/255, blue: 32/255)

    //MARK: Font Colors
    static let mainFont = Color(red: 221/255, green: 222/255, blue: 224/255) //MARK: A replacement for white font meant to be easier to read
    
    //MARK: Other Colors
    static let harvardCrimson = Color(red: 165/255, green: 28/255, blue: 48/255)
    static let girlPink = Color(red: 255/255, green: 105/255, blue: 180/255)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


