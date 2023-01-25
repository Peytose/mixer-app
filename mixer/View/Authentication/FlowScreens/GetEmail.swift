//
//  GetEmail.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct GetEmail: View {
    @FocusState private var focusState: Bool
    @Binding var email: String
    @State private var sentRequest = false
    @State private var disableButton = false
    let action: () -> Void
    @State var countdown = 5
    
    var body: some View {
        VStack(spacing: 10) {
            SignUpTextField(title: "What's your email?",
                            input: $email,
                            placeholder: "yourmum@milf.edu",
                            footnote: "For safety reasons, mixer is only available to college students at this time.",
                            keyboard: .emailAddress)
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { focusState = true } }
            .focused($focusState)
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            HStack {
                ContinueSignUpButton(text: "Submit", action: action)
                    .onTapGesture {
                        disableButton = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { disableButton = false }
                    }
                    .disabled(disableButton || email.isEmpty)
                    .opacity(disableButton || email.isEmpty ? 0.2 : 0.85)
                
                if sentRequest {
                    Button(action: action, label: {
                        ResendVerificationButton(remaining: $countdown)
                            .onTapGesture { countdown = 5 }
                    })
                    .disabled(countdown != 0)
                    .opacity(countdown != 0 ? 0.2 : 0.85)
                }
            }
            .padding(.bottom, 30)
        }
    }
}

fileprivate struct ResendVerificationButton: View {
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @Binding var remaining: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.DesignCodeWhite)
            .frame(width: 70, height: 50)
            .shadow(radius: 20, x: -8, y: -8)
            .shadow(radius: 20, x: 8, y: 8)
            .overlay {
                Text(remaining == 0 ? "Resend" : "\(remaining)")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.black)
                    .onReceive(timer) { _ in
                        if remaining == 0 {
                            timer.upstream.connect().cancel()
                        } else {
                            remaining -= 1
                        }
                    }
            }
            .opacity(0.85)
    }
}

struct GetEmail_Previews: PreviewProvider {
    static var previews: some View {
        GetEmail(email: .constant("")) {}
            .preferredColorScheme(.dark)
    }
}
