//
//  GetUsername.swift
//  mixer
//
//  Created by Peyton Lyons on 11/28/22.
//

import SwiftUI

struct GetUsername: View {
    let name: String
    @Binding var username: String
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                SignUpTextField(input: $username, title: "Last thing \(name)! Choose a username", placeholder: "ex. \(name.lowercased())_loves_mixer3", footnote: "This will not be changeable in the near future, so choose wisely. Username must be unique.", textfieldHeader: "Your username", keyboard: .default)
                
                Spacer()
            }
            .padding(.top)
            .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
            .overlay(alignment: .bottom) {
                if username.isEmpty {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: false)
                        .disabled(true)
                } else {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: true)
                        .disabled(false)
                }
        }
        }
    }
}

struct GetUsername_Previews: PreviewProvider {
    static var previews: some View {
        GetUsername(name: "Peyton",
                    username: .constant("")) { }
            .preferredColorScheme(.dark)
    }
}
