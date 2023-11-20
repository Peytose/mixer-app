//
//  ChangeProfileImageButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/19/23.
//

import Kingfisher
import SwiftUI

struct ChangeProfileImageButton: View {
    @Binding var imagePickerPresented: Bool
    let profileImageUrl: URL?
    
    var body: some View {
        VStack(alignment: .center) {
            Button { imagePickerPresented = true } label: {
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
    }
}
