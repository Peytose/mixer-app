//
//  GetPhoneView.swift
//  mixer
//
//  Created by Jose Martinez on 3/18/23.
//

import SwiftUI
import iPhoneNumberField

struct GetPhoneView: View {
    @Binding var phoneNumber: String
    @Binding var countryCode: String
    @State private var disableButton = false
    @State var isEditingNumber = false
    let action: () -> Void
    
    var body: some View {
        OnboardingPageViewContainer {
            PhoneNumberTextField(title: "My number is",
                                 footnote: "Message and data rates apply.",
                                 note: "We'll send you a code, it helps us keep your account secure.",
                                 textfieldHeader: "Your phone number",
                                 keyboard: .phonePad,
                                 input: $phoneNumber,
                                 countryCode: $countryCode,
                                 isEditingNumber: $isEditingNumber)
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", message: "Please enter a valid phone number" , action: action, isActive: !phoneNumber.isEmpty)
                .onTapGesture {
                    isEditingNumber = false
                    disableButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { disableButton = false }
                }
        }
    }
}

struct GetPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        GetPhoneView(phoneNumber: .constant(""),
                     countryCode: .constant("")) {  }
        .preferredColorScheme(.dark)
    }
}

fileprivate struct PhoneNumberTextField: View {
    let title: String
    let footnote: String
    let note: String
    let textfieldHeader: String
    let keyboard: UIKeyboardType
    @Binding var input: String
    @Binding var countryCode: String
    @Binding var isEditingNumber: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .largeTitle(weight: .semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 10)


            Text(note)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom)
                .padding(.top, -6)

            Text(textfieldHeader)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            iPhoneNumberField(text: $input, isEditing: $isEditingNumber) {
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
            .font(.title3)
            .tint(Color.mixerIndigo)
            .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: isEditingNumber ? 3 : 1)
                    .foregroundColor(Color.mixerIndigo)
            }
            
            Text(footnote)
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(width: DeviceTypes.ScreenSize.width * 0.9)
    }
}
