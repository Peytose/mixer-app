//
//  EnterBirthdayView.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI

struct EnterBirthdayView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.birthdayStr,
                            title: "When's your birthday?",
                            placeholder: "MM / DD / YYYY",
                            footnote: "Mixer uses your birthday for research and verification purposes. You can change the visibilty of your age in your settings.",
                            keyboard: .numberPad)
            .onChange(of: viewModel.birthdayStr) { newValue in
                viewModel.birthdayStr = newValue.applyPattern()
            }
        }
    }
}

struct EnterBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        EnterBirthdayView()
            .environmentObject(AuthViewModel.shared)
    }
}
