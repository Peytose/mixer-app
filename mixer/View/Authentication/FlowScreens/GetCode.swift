//
//  GetCode.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct GetCode: View {
    @State var countdown = 5
    @Binding var code: String
    
    let phoneNumber: String
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                SignUpTextField(input: $code,
                                 title: "Verify your number with a code",
                                 note: "Enter the security code we sent to \n\(phoneNumber)",
                                 placeholder: "My code is", textfieldHeader: "Your code",
                                 keyboard: .numberPad)
                
                Button(action: action, label: {
                    ResendVerificationTextButton(remaining: $countdown)
                        .onTapGesture { countdown = 5 }
                })
                .disabled(countdown != 0)
                .opacity(countdown != 0 ? 0.1 : 1)
                .padding(.top, 50)
                
                Spacer()
            }
            .padding(.top)
            .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
            .overlay(alignment: .bottom) {
                if code.isEmpty {
                    ContinueSignUpButton(text: "Submit", action: action, isActive: false)
                        .disabled(true)
                } else {
                    ContinueSignUpButton(text: "Submit", action: action, isActive: true)
                }
            }
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

fileprivate struct ResendVerificationTextButton: View {
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @Binding var remaining: Int
    
    var body: some View {
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
    }
}

struct GetCode_Previews: PreviewProvider {
    static var previews: some View {
        GetCode(code: .constant(""), phoneNumber: "2285965553") {}
            .preferredColorScheme(.dark)
    }
}
