//
//  EnterProfilePictureAndBioView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/23.
//

import SwiftUI

struct EnterProfilePictureAndBioView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        FlowContainerView {
            ScrollView {
                VStack(spacing: 50) {
                    SignUpPictureView(title: "Choose a profile picture",
                                      selectedImage: $viewModel.image)

                    Divider()
                        .padding(.horizontal)
                    
                    MultilineTextField(text: $viewModel.bio,
                                       title: "Tell us about yourself",
                                       placeholder: "Start here",
                                       keyboard: .default)

                    Spacer()
                }
                .padding(.bottom, 100)
            }
        }
    }
}

struct EnterProfilePictureAndBioView_Previews: PreviewProvider {
    static var previews: some View {
        EnterProfilePictureAndBioView()
            .environmentObject(AuthViewModel.shared)
    }
}
