//
//  ChangeProfileImageButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/19/23.
//

import Kingfisher
import SwiftUI
import PhotosUI

struct ChangeProfileImageButton: View {
    
    let profileImageUrl: URL?
    @State private var selectedImage: PhotosPickerItem?
    let saveFunc: (ProfileSaveType) -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            PhotosPicker(selection: $selectedImage, matching: .images) {
                KFImage(profileImageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .padding(2)
                    .background(.white, in: Circle())
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.theme.secondaryBackgroundColor, in: Circle())
                            .background(.white, in: Circle().stroke(lineWidth: 2))
                            .offset(x: -4, y: -4)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .onChange(of: selectedImage) { _ in
            Task {
                if let pickerItem = selectedImage,
                   let data = try? await pickerItem.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        saveFunc(.image(image))
                    }
                }
            }
        }
    }
}
