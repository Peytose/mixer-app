//
//  EnterUsernameView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/28/22.
//

import SwiftUI

struct EnterUsernameView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        FlowContainerView {
            SignUpTextField(input: $viewModel.username,
                            title: "Last thing \(viewModel.name)! Choose a username",
                            placeholder: "ex. \(viewModel.name.lowercased() + randomNumber())",
                            footnote: "This will not be changeable in the near future, so choose wisely. It must be unique.",
                            keyboard: .default,
                            isValidUsername: viewModel.isUsernameValid)
        }
    }
    
    
    private func randomNumber() -> String {
        let num = String(Int.random(in: 3...5))
        let num2 = String(Int.random(in: 3...5))
        return num + num2
    }
}

struct EnterUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterUsernameView()
            .environmentObject(AuthViewModel.shared)
    }
}
