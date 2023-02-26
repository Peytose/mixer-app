//
//  GetNameAndEmailView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/23.
//

import SwiftUI

struct GetNameAndEmailView: View {
    @Binding var name: String
    @Binding var email: String
    @State private var sentRequest = false
    @State private var disableButton = false
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                SignUpTextField(input: $name,
                                title: "Let's start with your name and email!",
                                placeholder: "your name",
                                keyboard: .default)
                
                SignUpTextField(input: $email,
                                placeholder: "you@school.edu",
                                footnote: "For safety reasons, mixer is only available to college students at this time.",
                                keyboard: .emailAddress)
                
                Spacer()
            }
            .padding(.top)
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .disabled(name.isEmpty || email.isEmpty)
                .opacity(name.isEmpty || email.isEmpty ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}

struct GetNameAndEmailView_Previews: PreviewProvider {
    static var previews: some View {
        GetNameAndEmailView(name: .constant(""),
                            email: .constant(""),
                            action: {  })
        .preferredColorScheme(.dark)
    }
}
