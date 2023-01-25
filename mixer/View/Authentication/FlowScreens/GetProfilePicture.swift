//
//  GetProfilePicture.swift
//  mixer
//
//  Created by Peyton Lyons on 11/25/22.
//

import SwiftUI

struct GetProfilePicture: View {
    let firstName: String
    @Binding var avatar: UIImage?
    @State private var image: Image?
    @State var imagePickerPresented = false
    let action: () -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 7) {
                Text("Last question \(firstName.capitalized)! What do you look like?")
                    .foregroundColor(.mainFont)
                    .font(.title.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 5)
                
                HStack {
                    Spacer()
                    
                    Button { imagePickerPresented.toggle() } label: {
                        if let image = image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "photo.circle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                        }
                    }
                    .foregroundColor(Color.mainFont)
                    .tint(Color.mixerIndigo)
                    
                    Spacer()
                }
                
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                Text("This acts as your profile picture. It will be public by default.")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .frame(width: 300)
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .padding(.bottom, 30)
        }
        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage) { ImagePicker(image: $avatar) }
    }
}

extension GetProfilePicture {
    func loadImage() {
        guard let avatar = avatar else { return }
        image = Image(uiImage: avatar)
    }
}

//struct GetProfilePicture_Previews: PreviewProvider {
//    static var previews: some View {
//        GetProfilePicture(selectedImage: <#Binding<UIImage?>#>, firstName: "Josey") {}
//            .preferredColorScheme(.dark)
//    }
//}
