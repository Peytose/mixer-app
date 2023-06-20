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
        OnboardingPageViewContainer {
            SignUpTextField(input: $username,
                            title: "Last thing \(name)! Choose a username",
                            placeholder: "ex. \(name.lowercased())_\(randomNumber())",
                            footnote: "This will not be changeable in the near future, so choose wisely. Username must be unique.",
                            textfieldHeader: "Your username",
                            keyboard: .default)
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action, isActive: !username.isEmpty)
        }
    }
    
    private func randomNumber() -> String {
        let num = String(Int.random(in: 3...5))
        let num2 = String(Int.random(in: 3...5))
        return num + num2
    }
}

struct GetUsername_Previews: PreviewProvider {
    static var previews: some View {
        GetUsername(name: "Peyton",
                    username: .constant("")) { }
            .preferredColorScheme(.dark)
    }
}
