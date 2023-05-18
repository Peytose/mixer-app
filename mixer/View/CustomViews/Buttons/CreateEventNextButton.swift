//
//  CreateEventNextButton.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import Foundation

import SwiftUI

struct CreateEventNextButton: View {
    let text: String
    var action: () -> Void
    var isActive: Bool
    
    var body: some View {
        Button(action: action) {
            if isActive {
                Capsule()
                    .fill(Color.mixerIndigo.gradient.opacity(0.8))
                    .longButtonFrame()
                    .shadow(color: Color.mixerIndigo.opacity(0.05), radius: 20, x: -8, y: -8)
                    .shadow(color: Color.mixerIndigo.opacity(0.05), radius: 20, x: 8, y: 8)
                    .overlay {
                        Text(text)
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)

            } else {
                Capsule()
                    .fill(Color.mixerSecondaryBackground)
                    .longButtonFrame()
                    .shadow(radius: 10, x: 0, y: 8)
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
}

struct CreateEventNextButton_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventNextButton(text: "Continue", action: {}, isActive: true)
    }
}
