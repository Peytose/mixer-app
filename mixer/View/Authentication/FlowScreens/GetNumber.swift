//
//  GetNumber.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI
import iPhoneNumberField

struct GetNumber: View {
    @FocusState private var focusState: Bool
    let firstName: String
    @Binding var phoneNumber: String
    @State private var disableButton = false
    let action: () -> Void
    
    var body: some View {
        VStack {
            PhoneNumberTextField(title: "\(firstName.capitalized), what's your number?",
                                 placeholder: "(123) 456-7890",
                                 footnote: "We will send a text with a verification code. Message and data rates apply.",
                                 keyboard: .phonePad,
                                 input: $phoneNumber)
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { focusState = true } }
            .focused($focusState)
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .onTapGesture {
                    disableButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                }
                .disabled(phoneNumber.isEmpty)
                .opacity(phoneNumber.isEmpty ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}

fileprivate struct PhoneNumberTextField: View {
    let title: String
    let placeholder: String
    let footnote: String
    let keyboard: UIKeyboardType
    var input: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .foregroundColor(.mainFont)
                .font(.title.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 5)
            
            iPhoneNumberField(placeholder, text: input)
                .flagHidden(false)
                .flagSelectable(true)
                .formatted()
                .foregroundColor(Color.mainFont)
                .font(.systemFont(ofSize: 25))
                .tint(Color.mixerIndigo)
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

struct GetNumber_Previews: PreviewProvider {
    static var previews: some View {
        GetNumber(firstName: "josey", phoneNumber: .constant("")) {}
            .preferredColorScheme(.dark)
    }
}
