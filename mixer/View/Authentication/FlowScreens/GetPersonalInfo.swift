//
//  GetPersonalInfo.swift
//  mixer
//
//  Created by Peyton Lyons on 2/28/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct GetPersonalInfo: View {
    let name: String
    @Binding var birthday: String
    @Binding var isValidBirthday: Bool
    @Binding var gender: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 50) {
            SignUpTextField(input: $birthday, title: "Just a few more details \(name.capitalized), when's your birthday?",
                            placeholder: "MM  DD  YYYY",
                            footnote: "Mixer uses your birthday for research and verification purposes. It will not be public.",
                            keyboard: .numberPad)
            .onChange(of: birthday) { newValue in birthday = newValue.applyPattern() }
            
            
            Divider().padding(.horizontal)
            
            GenderPicker(title: "Almost there! What's your gender?",
                         input: $gender,
                         placeholder: "",
                         footnote: "We use this for research purposes. It will not be public.")
            
            Spacer()
        }
        .padding(.top)
        .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
//        .overlay(alignment: .bottom) {
//            ContinueSignUpButton(text: "Continue", action: action)
//                .disabled(!isValidBirthday)
//                .opacity(!isValidBirthday ? 0.2 : 0.85)
//                .padding(.bottom, 30)
//        }
    }
}

struct GetPersonalInfo_Previews: PreviewProvider {
    static var previews: some View {
        GetPersonalInfo(name: "Peyton",
                        birthday: .constant(""),
                        isValidBirthday: .constant(false),
                        gender: .constant("Male")) {  }
            .preferredColorScheme(.dark)
    }
}

fileprivate struct GenderPicker: View {
    let title: String
    var input: Binding<String>
    let placeholder: String
    let footnote: String
    let genders = ["Female", "Male", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .foregroundColor(.mainFont)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 5)
            
            Picker(placeholder, selection: input) {
                ForEach(genders, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .foregroundColor(Color.mainFont)
            .font(.title3)
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
