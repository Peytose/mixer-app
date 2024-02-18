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

                    BioTextField(bio: $viewModel.bio,
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

fileprivate struct BioTextField: View {
    @Binding var bio: String
    var title: String?
    var placeholder: String
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title = title {
                Text(title)
                    .foregroundColor(.white)
                    .font(.title.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                TextField(placeholder, text: $bio, axis: .vertical)
                    .frame(width: DeviceTypes.ScreenSize.width / 1.3)
                    .lineLimit(3, reservesSpace: true)
                    .keyboardType(keyboard)
                    .disableAutocorrection(true)
                    .foregroundColor(.white)
                    .font(.body)
                    .tint(Color.theme.mixerIndigo)
                    .padding()
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 2)
                    }
                
                CharactersRemainView(currentCount: bio.count)
            }
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.2)
    }
}

fileprivate struct SignUpPictureView: View {
    var title: String?
    @Binding var selectedImage: UIImage?
    @State var imagePickerPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title = title {
                Text(title)
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
            }
            
            HStack {
                Spacer()
                
                ChangeImageButton(imageContext: .profile) { uiImage in
                    selectedImage = uiImage
                }
                .padding(.bottom, -5)
                
                Spacer()
            }
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.2)
    }
}
