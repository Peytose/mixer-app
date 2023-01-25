//
//  GetBirthday.swift
//  mixer
//
//  Created by Peyton Lyons on 11/24/22.
//

import SwiftUI

struct GetBirthday: View {
    @FocusState private var focusState: Bool
    let firstName: String
    @Binding var birthday: String
    @Binding var isValidBirthday: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            SignUpTextField(title: "Just a few more details \(firstName.capitalized), when's your birthday?",
                            input: $birthday,
                            placeholder: "MM  DD  YYYY",
                            footnote: "Mixer uses your birthday for research and verification purposes. It will not be public.",
                            keyboard: .numberPad)
            .onChange(of: birthday) { newValue in birthday = newValue.applyPattern() }
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { focusState = true } }
            .focused($focusState)
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .disabled(isValidBirthday)
                .opacity(isValidBirthday ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}

struct GetBirthday_Previews: PreviewProvider {
    static var previews: some View {
        GetBirthday(firstName: "josey", birthday: .constant(""), isValidBirthday: .constant(false)) {}
            .preferredColorScheme(.dark)
    }
}
