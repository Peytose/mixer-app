//
//  OnboardingPageViewContainer.swift
//  mixer
//
//  Created by Jose Martinez on 6/19/23.
//

import SwiftUI

struct OnboardingPageViewContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                content

                Spacer()
            }
            .padding(.top)
            .onAppear { hideKeyboard() }
            .onAppear { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) }
        }
    }
}

struct OnboardingPageViewContainer_Previews: PreviewProvider {
    @State static private var name: String = ""
    static var previews: some View {
        OnboardingPageViewContainer {
            SignUpTextField(input: $name,
                            title: "My name is",
                            placeholder: "John Doe",
                            footnote: "This is how it will appear in mixer",
                            textfieldHeader: "Your name",
                            keyboard: .default)
        }
        .preferredColorScheme(.dark)
    }
}
