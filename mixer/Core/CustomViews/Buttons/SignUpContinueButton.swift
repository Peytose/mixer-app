//
//  SignUpContinueButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct SignUpContinueButton: View {
    var message: String?
    var text: String
    var isButtonActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        VStack {
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                withAnimation(.spring()) {
                    action()
                }
            } label: {
                Capsule()
                    .fill(Color.theme.mixerIndigo.gradient)
                    .longButtonFrame()
                    .shadow(radius: 20, x: -8, y: -8)
                    .shadow(radius: 20, x: 8, y: 8)
                    .overlay {
                        Text(text)
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                    }
                    .contentShape(Rectangle())
                    .padding(.bottom, 20)
            }
        }
        .animation(Animation.timingCurve(0.2, 0.2, 0.2, 1))
        .opacity(isButtonActive ? 1 : 0.4)
        .disabled(!isButtonActive)
    }
}
