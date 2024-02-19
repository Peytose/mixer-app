//
//  ConfirmDeleteAccountView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/19/24.
//

import SwiftUI

struct ConfirmDeleteAccountView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.confirmUsername,
                            title: "Confirm Username",
                            note: "Please confirm your username to proceed with account deletion.",
                            placeholder: viewModel.user?.username ?? "Your Username",
                            footnote: "Enter your username exactly as it is. Deleting your account is permanent and cannot be undone. All your data will be permanently removed.",
                            keyboard: .default)
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

extension ConfirmDeleteAccountView {
    var sendEmailButton: some View {
        Button {
            viewModel.deleteAccount()
        } label: {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
        }
        .disabled(!(viewModel.confirmUsername == viewModel.user?.username))
        .opacity(viewModel.confirmUsername == viewModel.user?.username ? 1 : 0.3)
        .scaleEffect(viewModel.confirmUsername == viewModel.user?.username ? 1.2 : 1)
    }
}
