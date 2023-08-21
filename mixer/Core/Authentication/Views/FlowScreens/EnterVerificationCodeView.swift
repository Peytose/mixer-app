//
//  EnterVerificationCodeView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct EnterVerificationCodeView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var countdown = 5
    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.code,
                            title: "The code is",
                            note: "Enter the security code we sent to\n\(viewModel.phoneNumber)",
                            placeholder: "Start here",
                            keyboard: .numberPad)
            
            ResendVerificationTextButton(remaining: $countdown) { /* need to put func here */ }
                .disabled(countdown != 0)
                .opacity(countdown != 0 ? 0.2 : 1)
                .onTapGesture { countdown = 5 }
                .padding(.top, 50)
        }
    }
}

struct EnterVerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterVerificationCodeView()
            .environmentObject(AuthViewModel.shared)
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
