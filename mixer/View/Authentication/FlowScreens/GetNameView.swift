//
//  GetNameAndPhoneView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/23.
//

import SwiftUI
import iPhoneNumberField

struct GetNameView: View {
    @Binding var name: String
    let action: () -> Void
    
    var body: some View {
        OnboardingPageViewContainer {
            SignUpTextField(input: $name,
                            title: "My name is",
                            placeholder: "John Doe",
                            footnote: "This is how it will appear in mixer",
                            textfieldHeader: "Your name",
                            keyboard: .default)
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", message: "Please enter a name", action: action, isActive: !name.isEmpty)
        }
    }
}

struct GetNameAndPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        GetNameView(name: .constant("")) { }
        .preferredColorScheme(.dark)
    }
}
