//
//  EnterPhoneNumberView.swift
//  mixer
//
//  Created by Jose Martinez on 3/18/23.
//

import SwiftUI
import iPhoneNumberField

struct EnterPhoneNumberView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var isEditingNumber = false
    
    var body: some View {
        FlowContainerView {
            PhoneNumberTextField(title: "My number is",
                                 footnote: "Message and data rates may apply.",
                                 note: "We'll send you a code; it helps us keep your account secure.",
                                 keyboard: .phonePad,
                                 input: $viewModel.phoneNumber,
                                 countryCode: $viewModel.countryCode,
                                 isEditingNumber: $isEditingNumber)
            .onDisappear {
                isEditingNumber = false
            }
        }
    }
}

struct EnterPhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPhoneNumberView()
            .environmentObject(AuthViewModel.shared)
    }
}

fileprivate struct PhoneNumberTextField: View {
    let title: String
    let footnote: String
    let note: String
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
                .padding(.bottom, 4)

            Text(note)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
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
            .foregroundColor(Color.white)
            .font(.title3)
            .tint(Color.theme.mixerIndigo)
            .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: isEditingNumber ? 3 : 1)
                    .foregroundColor(Color.theme.mixerIndigo)
            }
            
            Text(footnote)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(width: DeviceTypes.ScreenSize.width * 0.9)
    }
}
