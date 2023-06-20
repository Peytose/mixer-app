//
//  ContinueSignUpButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct ContinueSignUpButton: View {
    let text: String
    var message: String?
    var action: () -> Void
    var isActive: Bool
    
    var body: some View {
        Button(action: action) {
            if isActive {
                Capsule()
                    .fill(Color.mixerIndigo.gradient)
                    .longButtonFrame()
                    .shadow(radius: 20, x: -8, y: -8)
                    .shadow(radius: 20, x: 8, y: 8)
                    .overlay {
                        Text(text)
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)


            } else {
                VStack {
                    if let message = message {
                        Text(message)
                            .font(.subheadline)
                    }
                    
                    Capsule()
                        .stroke(lineWidth: 2)
                        .fill(Color.mixerIndigo.opacity(0.4))
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
        }
        .animation(Animation.timingCurve(0.2, 0.2, 0.2, 1))
        .disabled(!isActive)
    }
}
