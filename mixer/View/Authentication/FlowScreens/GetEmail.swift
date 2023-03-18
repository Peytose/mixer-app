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
        VStack {
            SignUpTextField2(input: $email,
                            title: "What's your email?",
                            note: "Don't lose access to your account, verify your email",
                            placeholder: "you@school.edu",
                            footnote: "For safety reasons, mixer is only available to college students at this time.",
                            keyboard: .emailAddress)
            
            Spacer()
        }
        .padding(.top)
        .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .onTapGesture {
                    disableButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                }
                .disabled(email.isEmpty)
                .opacity(email.isEmpty ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}



struct GetEmail_Previews: PreviewProvider {
    static var previews: some View {
        GetEmail(name: "josey", email: .constant("")) {  }
            .preferredColorScheme(.dark)
    }
}
