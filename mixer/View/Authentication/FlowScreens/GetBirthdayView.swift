//
//  GetBirthdayView.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct GetBirthdayView: View {
    let name: String
    @Binding var birthday: String
    @Binding var isValidBirthday: Bool
    @Binding var gender: String
    let action: () -> Void
    
    var body: some View {
        OnboardingPageViewContainer {
            SignUpTextField(input: $birthday,
                            title: "When's your birthday?",
                            placeholder: "MM / DD / YYYY",
                            footnote: "Mixer uses your birthday for research and verification purposes. Your age will be public",
                            keyboard: .numberPad)
            .onChange(of: birthday) { newValue in birthday = newValue.applyPattern() }
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action, isActive: isValidBirthday)
        }
    }
}

struct GetBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        GetBirthdayView(name: "Peyton",
                        birthday: .constant(""),
                        isValidBirthday: .constant(false),
                        gender: .constant("Male")) {  }
            .preferredColorScheme(.dark)
    }
}
