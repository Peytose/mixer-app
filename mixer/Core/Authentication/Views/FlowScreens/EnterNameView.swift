//
//  EnterNameView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/23.
//

import SwiftUI
import iPhoneNumberField

enum FocusedField {
    case firstName, lastName
}

struct EnterNameView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var focusedField: FocusedField?

    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.firstName,
                            title: "Let's get acquainted! What's your name?",
                            note: "First Name",
                            placeholder: "John",
                            keyboard: .default,
                            disableAutocorrection: true)
            .focused($focusedField, equals: .firstName)

            
            SignUpTextField(input: $viewModel.lastName,
                            title: "",
                            note: "Last Name",
                            placeholder: "Doe",
                            footnote: "For verification and to ensure your security, we need your real first and last name. These will not be changeable for security reasons, but you'll have the option to set a display name of your choice in your profile settings.",
                            keyboard: .default,
                            disableAutocorrection: true)
            .focused($focusedField, equals: .lastName)

        }
        .onSubmit {
            if focusedField == .firstName {
                focusedField = .lastName
            } else {
                focusedField = nil
            }
        }
    }
}

struct EnterNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterNameView()
            .environmentObject(AuthViewModel.shared)
    }
}
