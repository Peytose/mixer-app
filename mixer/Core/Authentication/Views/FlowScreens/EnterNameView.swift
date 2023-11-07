//
//  EnterNameView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/23.
//

import SwiftUI
import iPhoneNumberField

struct EnterNameView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.firstName,
                            title: "Let's get acquainted! What's your name?",
                            placeholder: "John",
                            keyboard: .default,
                            disableAutocorrection: true)
            
            SignUpTextField(input: $viewModel.lastName,
                            title: "",
                            placeholder: "Doe",
                            footnote: "For verification and to ensure your security, we need your real first and last name. These will not be changeable for security reasons, but you'll have the option to set a display name of your choice in your profile settings.",
                            keyboard: .default,
                            disableAutocorrection: true)
        }
    }
}

struct EnterNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterNameView()
            .environmentObject(AuthViewModel.shared)
    }
}
