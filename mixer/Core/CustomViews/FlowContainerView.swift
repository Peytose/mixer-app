//
//  FlowContainerView.swift
//  mixer
//
//  Created by Jose Martinez on 6/19/23.
//

import SwiftUI

struct FlowContainerView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                content

                Spacer()
            }
            .padding(.top)
            .onAppear {
                hideKeyboard()
            }
        }
    }
}

struct FlowContainerView_Previews: PreviewProvider {
    @State static private var name: String = ""
    static var previews: some View {
        FlowContainerView {
            SignUpTextField(input: $name,
                            title: "My name is",
                            placeholder: "John Doe",
                            footnote: "This is how it will appear in mixer",
                            keyboard: .default)
        }
        .preferredColorScheme(.dark)
    }
}
