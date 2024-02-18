//
//  EnterEmailView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct EnterEmailView: View {
    @Environment (\.dismiss) private var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.email,
                            title: "Confirm Email",
                            note: "Ensure your account is linked to the correct university",
                            placeholder: "you@university.edu",
                            footnote: "Enter your university email. If you've entered it incorrectly before, use this opportunity to correct it. Mixer is for university affiliates.",
                            keyboard: .emailAddress)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                PresentationBackArrowButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                sendEmailButton
            }
        }
    }
}

extension EnterEmailView {
    var sendEmailButton: some View {
        Button {
            viewModel.sendVerificationEmail()
            dismiss()
        } label: {
            Image(systemName: "arrow.up.circle")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
        }
        .disabled(!viewModel.email.isValidEmail || viewModel.isLoading)
        .opacity(viewModel.email.isValidEmail ? 1 : 0.3)
        .scaleEffect(viewModel.email.isValidEmail ? 1.2 : 1)
    }
}
