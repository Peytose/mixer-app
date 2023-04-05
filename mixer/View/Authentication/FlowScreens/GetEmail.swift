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
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                SignUpTextField2(input: $email,
                                 title: "What's your email?",
                                 note: "Don't lose access to your account, verify your email",
                                 placeholder: "you@school.edu",
                                 footnote: "For safety reasons, mixer is only available to college students at this time.", textfieldHeader: "Your email",
                                 keyboard: .emailAddress)
                
                Spacer()
            }
            .padding(.top)
            .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
            .overlay(alignment: .bottom) {
                if email.isEmpty {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: false)
                        .onTapGesture {
                            disableButton = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                        }
                        .disabled(true)
                } else {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: true)
                        .onTapGesture {
                            disableButton = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                        }
                }
            }
        }
    }
}



struct GetEmail_Previews: PreviewProvider {
    static var previews: some View {
        GetEmail(name: "josey", email: .constant("")) {  }
            .preferredColorScheme(.dark)
    }
}
