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
        VStack {
            SignUpTextField(input: $username,
                            title: "Last question \(name)! Choose a username",
                            placeholder: "ex. \(name.lowercased())_loves_mixer3",
                            footnote: "This will not be changeable in the near future, so choose wisely. Username must be unique.",
                            keyboard: .default)
            
            Spacer()
        }
        .padding(.top)
        .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
//        .overlay(alignment: .bottom) {
//            ContinueSignUpButton(text: "Continue", action: action)
//                .disabled(username.isEmpty)
//                .opacity(username.isEmpty ? 0.2 : 0.85)
//                .padding(.bottom, 30)
//        }
    }
}

struct GetUsername_Previews: PreviewProvider {
    static var previews: some View {
        GetUsername(name: "Peyton",
                    username: .constant("")) { }
            .preferredColorScheme(.dark)
    }
}
