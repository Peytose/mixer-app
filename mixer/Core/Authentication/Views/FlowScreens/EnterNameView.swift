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
            SignUpTextField(input: $viewModel.name,
                            title: "My full name is",
                            placeholder: "John Doe",
                            footnote: "We ask for your full name for verification purposes. It is unchangable in-app. Don't worry, you can alter your display name in your settings.",
                            keyboard: .default)
        }
    }
}

struct EnterNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterNameView()
            .environmentObject(AuthViewModel.shared)
    }
}
