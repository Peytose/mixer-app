//
//  GetUsername.swift
//  mixer
//
//  Created by Peyton Lyons on 11/28/22.
//

import SwiftUI

struct GetUsername: View {
    let firstName: String
    let lastName: String
    @FocusState private var focusState: Bool
    @Binding var username: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            SignUpTextField(title: "Choose a username",
                            input: $username,
                            placeholder: "ex. \(firstName.lowercased()).\(lastName.lowercased())123",
                            footnote: "This will not be changeable in the near future, so choose wisely. All usernames are unique.",
                            keyboard: .default)
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { focusState = true } }
            .focused($focusState)
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .disabled(username.isEmpty)
                .opacity(username.isEmpty ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}

struct GetUsername_Previews: PreviewProvider {
    static var previews: some View {
        GetUsername(firstName: "Josey", lastName: "Martinez", username: .constant("")) {}
            .preferredColorScheme(.dark)
    }
}
