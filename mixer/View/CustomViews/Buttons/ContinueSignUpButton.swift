//
//  ContinueSignUpButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct ContinueSignUpButton: View {
    let text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.mixerIndigo)
                .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                .shadow(radius: 20, x: -8, y: -8)
                .shadow(radius: 20, x: 8, y: 8)
                .overlay {
                    Text(text)
                        .font(.body.weight(.medium))
                        .foregroundColor(.white)
                }
        }
    }
}
