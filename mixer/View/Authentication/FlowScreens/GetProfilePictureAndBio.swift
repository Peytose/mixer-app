//
//  GetProfilePictureAndBio.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/23.
//

import SwiftUI

struct GetProfilePictureAndBio: View {
    @Binding var bio: String
    @State var image: Image?
    @State var imagePickerPresented = false
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                SignUpPictureView(title: "Choose a profile picture.",
                                  image: $image,
                                  imagePickerPresented: $imagePickerPresented)
                
                Divider().padding(.horizontal)
                
                BioTextField(bio: $bio,
                             title: "Write a bio.",
                             placeholder: "bio",
                             keyboard: .default)
                
                Spacer()
            }
            .padding(.top)
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .padding(.bottom, 30)
        }
    }
}

struct GetProfilePictureAndBio_Previews: PreviewProvider {
    static var previews: some View {
        GetProfilePictureAndBio(bio: .constant(""), action: {  })
            .preferredColorScheme(.dark)
    }
}

fileprivate struct BioTextField: View {
    @Binding var bio: String
    var title: String?
    var placeholder: String
    var footnote: String?
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title = title {
                Text(title)
                    .foregroundColor(.mainFont)
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
                        .foregroundColor(Color.mainFont)
                        .font(.body)
                        .tint(Color.mixerIndigo)
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
    @State private var selectedImage: UIImage?
    @Binding var image: Image?
    @Binding var imagePickerPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title = title {
                Text(title)
                    .foregroundColor(.mainFont)
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
            }
            
            HStack {
                Spacer()
                
                Button { self.imagePickerPresented.toggle() } label: {
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage) {
                ImagePicker(image: $selectedImage)
            }
            .padding(.bottom, -5)
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.2)
    }
}

extension SignUpPictureView {
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        image = Image(uiImage: selectedImage)
    }
}

fileprivate struct CharactersRemainView: View {
    var currentCount: Int
    
    var body: some View {
        Text("Bio: ")
            .font(.callout)
            .foregroundColor(.secondary)
        +
        Text("\(100 - currentCount)")
            .bold()
            .font(.callout)
            .foregroundColor(currentCount <= 100 ? .mixerIndigo : Color(.systemPink))
        +
        Text(" characters remain")
            .font(.callout)
            .foregroundColor(.secondary)
    }
}
