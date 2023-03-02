//
//  GetNameAndPhoneView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/23.
//

import SwiftUI
import iPhoneNumberField

struct GetNameAndPhoneView: View {
    @Binding var name: String
    @Binding var phoneNumber: String
    @Binding var countryCode: String
    @State private var disableButton = false
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 50) {
            SignUpTextField(input: $name,
                            title: "Hey, let's start with your name!",
                            placeholder: "your name",
                            keyboard: .default)
            
            Divider().padding(.horizontal)
            
            PhoneNumberTextField(title: "And what's your number?",
                                 footnote: "We will send a text with a verification code. Message and data rates apply.",
                                 keyboard: .phonePad,
                                 input: $phoneNumber,
                                 countryCode: $countryCode)
            
            Spacer()
        }
        .padding(.top)
        .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .onTapGesture {
                    disableButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                }
                .disabled(name.isEmpty || phoneNumber.isEmpty)
                .opacity(name.isEmpty || phoneNumber.isEmpty ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}

struct GetNameAndPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        GetNameAndPhoneView(name: .constant(""),
                            phoneNumber: .constant(""),
                            countryCode: .constant(""),
                            action: {  })
        .preferredColorScheme(.dark)
    }
}


fileprivate struct PhoneNumberTextField: View {
    let title: String
    let footnote: String
    let keyboard: UIKeyboardType
    @Binding var input: String
    @Binding var countryCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .foregroundColor(.mainFont)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 5)
            
            iPhoneNumberField(text: $input) {
                if let code = $0.phoneNumber?.countryCode {
                    DispatchQueue.main.async {
                        countryCode = "+\(code)"
                    }
                }
            }
                .flagHidden(false)
                .flagSelectable(true)
                .prefixHidden(false)
                .formatted()
                .foregroundColor(Color.mainFont)
                .font(.title2)
                .tint(Color.mixerIndigo)
                .padding(.bottom, -5)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            Text(footnote)
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.2)
    }
}
