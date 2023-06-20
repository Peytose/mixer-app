//
//  GetCode.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct GetCode: View {
    @Binding var code: String
    
    @State var countdown = 5
    let phoneNumber: String
    let action: () -> Void
    
    var body: some View {
        OnboardingPageViewContainer {
            SignUpTextField(input: $code,
                            title: "Verify your number with a code",
                            note: "Enter the security code we sent to \n\(phoneNumber)",
                            placeholder: "My code is", textfieldHeader: "Your code",
                            keyboard: .numberPad)
            
            ResendVerificationTextButton(remaining: $countdown, action: action)
                .disabled(countdown != 0)
                .opacity(countdown != 0 ? 0.2 : 1)
                .onTapGesture { countdown = 5 }
                .padding(.top, 50)
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", message: "Please enter a valid code", action: action, isActive: !code.isEmpty)
        }
    }
}

fileprivate struct ResendVerificationTextButton: View {
    @Binding var remaining: Int
    let action: () -> Void
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        Button(action: action, label: {
            VStack {
                Text("Didn't receive a code?")
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                    .overlay {
                        Rectangle()
                            .fill(.white)
                            .frame(height: 1)
                            .offset(y: 10)
                            .padding(.horizontal, 0)
                    }
                    .onReceive(timer) { _ in
                        if remaining == 0 {
                            timer.upstream.connect().cancel()
                        } else {
                            remaining -= 1
                        }
                    }
            }
        })
    }
}

struct GetCode_Previews: PreviewProvider {
    static var previews: some View {
        GetCode(code: .constant(""), phoneNumber: "2285965553") {}
            .preferredColorScheme(.dark)
    }
}
