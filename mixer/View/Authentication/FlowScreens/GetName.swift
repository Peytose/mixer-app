//
//  GetName.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

struct GetName: View {
    @FocusState private var focusState: Bool
    @Binding var firstName: String
    @Binding var lastName: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            SignUpNameTextField(title: "Howdy! What's your name?",
                                firstName: $firstName,
                                lastName: $lastName,
                                placeholder1: "First name",
                                placeholder2: "Last name",
                                footnote: "Only hosts can see your full name by default.",
                                keyboard: .default)
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { focusState = true } }
            .focused($focusState)
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .disabled(firstName.isEmpty || lastName.isEmpty)
                .opacity(firstName.isEmpty || lastName.isEmpty ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}

fileprivate struct SignUpNameTextField: View {
    var title: String
    var firstName: Binding<String>
    var lastName: Binding<String>
    var placeholder1: String
    var placeholder2: String
    var footnote: String
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.mainFont)
                .font(.title.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 5)
            
            TextField(placeholder1, text: firstName)
                .keyboardType(keyboard)
                .disableAutocorrection(true)
                .foregroundColor(Color.mainFont)
                .font(.system(size: 25))
                .tint(Color.purple)
                .padding(.bottom, -5)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            TextField(placeholder2, text: lastName)
                .keyboardType(keyboard)
                .disableAutocorrection(true)
                .foregroundColor(Color.mainFont)
                .font(.system(size: 25))
                .tint(Color.purple)
                .padding(.bottom, -5)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            Text(footnote)
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(width: 300)
    }
}

struct GGetName_Previews: PreviewProvider {
    static var previews: some View {
        GetName(firstName: .constant(""), lastName: .constant("")) {}
            .preferredColorScheme(.dark)
    }
}
