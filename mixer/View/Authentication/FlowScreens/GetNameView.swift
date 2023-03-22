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
        VStack {
            SignUpTextField2(input: $name,
                            title: "My name is",
                            placeholder: "John Doe",
                            textfieldHeader: "Your name", keyboard: .default)

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
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.2 : 0.85)
                .padding(.bottom, 30)
        }
    }
}

struct GetNameAndPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        GetNameView(name: .constant(""), action: {  })
        .preferredColorScheme(.light)
    }
}
