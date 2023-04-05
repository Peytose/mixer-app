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
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                SignUpTextField2(input: $birthday,
                                 title: "When's your birthday?",
                                 placeholder: "MM / DD / YYYY",
                                 footnote: "Mixer uses your birthday for research and verification purposes. Your age will be public",
                                 keyboard: .numberPad)
                .onChange(of: birthday) { newValue in birthday = newValue.applyPattern() }
                
                Spacer()
            }
            .padding(.top)
            .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
            .overlay(alignment: .bottom) {
                if !isValidBirthday {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: false)
                        .disabled(true)
                } else {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: true)
                }
            }
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
