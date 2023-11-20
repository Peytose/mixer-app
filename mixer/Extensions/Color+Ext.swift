//
//  Color+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let backgroundColor          = Color("BackgroundColor")
    let secondaryBackgroundColor = Color("SecondaryBackgroundColor")

    // MARK: - Chosen Gradients
    let mixerPurpleGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 112/255, green: 63/255, blue: 213/255),
            Color(red: 76/255, green: 20/255, blue: 178/255)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let profileGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(red: 10/255, green: 10/255, blue: 12/255), location: 0),
            .init(color: .clear, location: 1)
        ]),
        startPoint:.top,
        endPoint: .bottom
    )
    
    let gradientPurple1 = Color(red: 112/255, green: 63/255, blue: 213/255)
    let gradientPurple2 = Color(red: 76/255, green: 20/255, blue: 178/255)
    
    
    // MARK: - Text Colors
    let lightText = Color(UIColor.lightText)
    let darkText = Color(UIColor.darkText)
    let placeholderText = Color(UIColor.placeholderText)

    // MARK: - Label Colors
    let label = Color(UIColor.label)
    let secondaryLabel = Color(UIColor.secondaryLabel)
    let tertiaryLabel = Color(UIColor.tertiaryLabel)
    let quaternaryLabel = Color(UIColor.quaternaryLabel)
    
    // MARK: - Background Colors
    let systemBackground = Color(UIColor.systemBackground)
    let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    
    let SlightlyDarkerBlueBackground = Color(red: 8/255, green: 8/255, blue: 10/255)
    let SlightlyBlueBackground = Color(red: 10/255, green: 10/255, blue: 12/255)
    let SpotifyDarkGray = Color(red: 18/255, green: 18/255, blue: 18/255)


    // MARK: - Fill Colors
    let systemFill = Color(UIColor.systemFill)
    let secondarySystemFill = Color(UIColor.secondarySystemFill)
    let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
    
    // MARK: - Grouped Background Colors
    let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
    
    // MARK: - Gray Colors
    let systemGray = Color(UIColor.systemGray)
    let systemGray2 = Color(UIColor.systemGray2)
    let systemGray3 = Color(UIColor.systemGray3)
    let systemGray4 = Color(UIColor.systemGray4)
    let systemGray5 = Color(UIColor.systemGray5)
    let systemGray6 = Color(UIColor.systemGray6)
    
    // MARK: - Other Colors
    let separator = Color(UIColor.separator)
    let opaqueSeparator = Color(UIColor.opaqueSeparator)
    let link = Color(UIColor.link)
    
    let DesignCodeWhite = Color(red: 242/255, green: 246/255, blue: 255/255)
    let Offwhite2 = Color(red: 245/255, green: 246/255, blue: 250/255)
    let QRCodeBackground = Color(red: 15/255, green: 18/255, blue: 28/255)
    let tertiaryBackground = Color(red: 39/255, green: 38/255, blue: 44/255)

    
    //MARK: Chosen Colors
    let mixerPurple = Color(red: 90/255, green: 60/255, blue: 196/255) //MARK: The main purple we are using s more of an indigo)
    let mixerIndigo = Color(red: 124/255, green: 65/255, blue: 254/255) //MARK: The main purple we are ng (its more of an indigo)
    let mixerBlue = Color(red: 25/255, green: 99/255, blue: 221/255) //MARK: The main purple we are using (its more of an indigo)

    //MARK: Font Colors
    let mainFont = Color(red: 221/255, green: 222/255, blue: 224/255) //MARK: A replacement for white font meant to be easier to read
    
    //MARK: Other Colors
    let harvardCrimson = Color(red: 165/255, green: 28/255, blue: 48/255)
    let girlPink = Color(red: 255/255, green: 105/255, blue: 180/255)
}


