//
//  AuthFlow.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI
import FirebaseAuth

struct AuthFlow: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var authState = AuthFlowViewState.enterName
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            viewModel.viewForState(authState)
                .padding(.top, 30)
                .transition(.move(edge: .leading))
            
            if viewModel.isOnboardingScreensVisible {
                // DEBUG: insert onboarding screens here
            }
            
            if viewModel.isLoading { LoadingView() }
        }
        .overlay(alignment: .bottom) {
            SignUpContinueButton(message: viewModel.buttonMessage(for: authState),
                                 text: viewModel.buttonText(for: authState),
                                 isButtonActive: viewModel.isButtonActiveForState(authState)) {
                viewModel.actionForState($authState)
            }
            .disabled(viewModel.isLoading)
        }
        .overlay(alignment: .topLeading) {
            if authState != .enterName {
                BackArrowButton {
                    viewModel.previous($authState)
                }
                .padding(.horizontal, 4)
                .padding(.top, 5)
            }
        }
        .onChange(of: viewModel.isLoggedOut) { newValue in
            if newValue { authState = .enterName }
        }
        .withAlerts(currentAlert: $viewModel.currentAlert)
    }
}

struct AuthFlow_Previews: PreviewProvider {
    static var previews: some View {
        AuthFlow()
            .preferredColorScheme(.dark)
            .environmentObject(AuthViewModel.shared)
    }
}
