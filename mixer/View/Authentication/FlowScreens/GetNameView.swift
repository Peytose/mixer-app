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
    @State private var disableButton = false
    
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                SignUpTextField2(input: $name,
                                title: "My name is",
                                placeholder: "John Doe",
                                 footnote: "This is how it will appear in mixer", textfieldHeader: "Your name", keyboard: .default)

                Spacer()
            }
            .padding(.top)
            .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
            .overlay(alignment: .bottom) {
                if name.isEmpty {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: false)
                        .onTapGesture {
                            disableButton = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                        }
                        .disabled(true)
                } else {
                    ContinueSignUpButton(text: "Continue", action: action, isActive: true)
                        .onTapGesture {
                            disableButton = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                        }
                }
        }
        }
    }
}

struct GetNameAndPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        GetNameView(name: .constant(""), action: {  })
        .preferredColorScheme(.light)
    }
}
