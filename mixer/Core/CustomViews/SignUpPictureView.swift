//
//  SignUpPictureView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/24/24.
//

import SwiftUI

struct SignUpPictureView: View {
    var title: String?
    @Binding var selectedImage: UIImage?
    var footnote: String?
    
    @State var imagePickerPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                
                Spacer()
            }
            
            if let footnote = footnote {
                Text(footnote)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .textFieldFrame()
    }
}
