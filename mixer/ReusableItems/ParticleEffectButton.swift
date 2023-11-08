//
//  ParticleEffectButton.swift
//  mixer
//
//  Created by Peyton Lyons on 8/30/23.
//

import SwiftUI

struct ParticleEffectButton: View {
    var systemImage: String
    var status: Bool
    var activeTint: Color
    var inActiveTint: Color
    var frameSize: CGFloat = 24 // Default size similar to .title2
    let onTap: () -> ()
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: systemImage)
                .particleEffect(
                    systemImage: systemImage,
                    font: .body,
                    status: status,
                    activeTint: activeTint,
                    inActiveTint: inActiveTint
                )
//                .frame(width: frameSize, height: frameSize) // Set the frame size
                .font(.title3.weight(.medium))
                .contentShape(Rectangle())
                .foregroundColor(status ? activeTint : inActiveTint)
        }
    }
}
