//
//  SignUpContinueButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct SignUpContinueButton: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var state: AuthFlowViewState
    
    var body: some View {
        VStack {
            if let message = state.buttonMessage, !viewModel.isButtonActiveForState(state) {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                withAnimation(.spring()) {
                    viewModel.actionForState($state)
                }
            } label: {
                Capsule()
                    .fill(Color.theme.mixerIndigo.gradient.opacity(viewModel.isButtonActiveForState(state) ? 1 : 0.4))
                    .longButtonFrame()
                    .shadow(radius: 20, x: -8, y: -8)
                    .shadow(radius: 20, x: 8, y: 8)
                    .overlay {
                        Text(state.buttonText)
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                    }
                    .contentShape(Rectangle())
                    .padding(.bottom, 20)
            }
        }
        .animation(Animation.timingCurve(0.2, 0.2, 0.2, 1))
        .disabled(!viewModel.isButtonActiveForState(state))
    }
}
