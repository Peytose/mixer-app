//
//  ChangeImageButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/19/23.
//

import Kingfisher
import SwiftUI
import PhotosUI

struct ChangeImageButton: View {
    
    var imageUrl: String? = ""
    var imageContext: ImageContext
    @State private var selectedImage: PhotosPickerItem?
    @State private var uploadedImage: UIImage?
    let saveFunc: (UIImage) -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            PhotosPicker(selection: $selectedImage, matching: .images) {
                imageToDisplay()
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .onChange(of: selectedImage) { _ in
            Task {
                if let pickerItem = selectedImage,
                   let data = try? await pickerItem.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        uploadedImage = image
                        saveFunc(image)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func imageToDisplay() -> some View {
        if let uploadedImage = uploadedImage {
            Image(uiImage: uploadedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .padding(2)
                .background(.white, in: Circle())
                .overlay(alignment: .bottomTrailing) {
                    pencilOverlay()
                }
        } else if let imageUrl = imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .padding(2)
                .background(.white, in: Circle())
                .overlay(alignment: .bottomTrailing) {
                    pencilOverlay()
                }
        } else {
            switch imageContext {
            case .profile:
                Image(.defaultAvatar)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .padding(2)
                    .background(.white, in: Circle())
                    .overlay(alignment: .bottomTrailing) {
                        pencilOverlay()
                    }
            case .eventFlyer:
                VStack {
                    Text("First, upload a flyer for your event!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Select image")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "hand.point.up")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(width: 22, height: 22, alignment: .center)
                    }
                }
                .frame(maxWidth: DeviceTypes.ScreenSize.width,
                       minHeight: DeviceTypes.ScreenSize.height / 5)
                .background(alignment: .center) {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func pencilOverlay() -> some View {
        Image(systemName: "pencil")
            .imageScale(.large)
            .foregroundColor(.white)
            .padding(5)
            .background(Color.theme.secondaryBackgroundColor, in: Circle())
            .background(.white, in: Circle().stroke(lineWidth: 2))
            .offset(x: -4, y: -4)
    }
}
