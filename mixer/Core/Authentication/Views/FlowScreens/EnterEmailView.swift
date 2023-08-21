//
//  EnterEmailView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct EnterEmailView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.email,
                            title: "What's your email?",
                            note: "Don't lose access to your account, verify your email",
                            placeholder: "you@school.edu",
                            footnote: "For safety reasons, mixer is only available to college students at this time.",
                            keyboard: .emailAddress)
        }
    }
}

struct EnterEmailView_Previews: PreviewProvider {
    static var previews: some View {
        EnterEmailView()
            .environmentObject(AuthViewModel.shared)
    }
}
