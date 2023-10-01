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
            SignUpContinueButton(state: $authState)
                .disabled(viewModel.isLoading)
        }
        .overlay(alignment: .topLeading) {
            if authState != .enterName {
                backArrowButton
                    .padding(.horizontal, 4)
                    .padding(.top, 5)
            }
        }
        .onOpenURL { url in
            viewModel.handleVerificationEmail(url) { success in
                if success && authState == .enterEmail {
                    viewModel.next($authState)
                }
            }
        }
        .onChange(of: viewModel.isLoggedOut) { newValue in
            if newValue { authState = .enterName }
        }
        .alert(item: $viewModel.currentAlert) { alertType in
            hideKeyboard()
            
            switch alertType {
            case .regular(let alertItem):
                guard let item = alertItem else { break }
                return item.alert
            case .confirmation(let confirmationAlertItem):
                guard let item = confirmationAlertItem else { break }
                return item.alert
            }
            
            return Alert(title: Text("Unexpected Error"))
        }
    }
}

struct AuthFlow_Previews: PreviewProvider {
    static var previews: some View {
        AuthFlow()
            .preferredColorScheme(.dark)
            .environmentObject(AuthViewModel.shared)
    }
}


extension AuthFlow {
    var backArrowButton: some View {
        Button { viewModel.previous($authState) } label: {
            Image(systemName: "arrow.left")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
}
