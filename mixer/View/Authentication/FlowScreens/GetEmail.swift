//
//  GetEmail.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct GetEmail: View {
    let name: String
    @Binding var email: String
    @State private var sentRequest = false
    @State private var disableButton = false
    let action: () -> Void
    
    var body: some View {
        OnboardingPageViewContainer {
            SignUpTextField(input: $email,
                            title: "What's your email?",
                            note: "Don't lose access to your account, verify your email",
                            placeholder: "you@school.edu",
                            footnote: "For safety reasons, mixer is only available to college students at this time.", textfieldHeader: "Your email",
                            keyboard: .emailAddress)
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", message: "Please enter a valid school email", action: action, isActive: !email.isEmpty)
                .onTapGesture {
                    disableButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { disableButton = false }
                }
                .disabled(disableButton)
        }
    }
}



struct GetEmail_Previews: PreviewProvider {
    static var previews: some View {
        GetEmail(name: "josey", email: .constant("")) {  }
            .preferredColorScheme(.dark)
    }
}
