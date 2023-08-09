//
//  AvatarView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/4/23.
//

import SwiftUI
import Kingfisher

struct AvatarView: View {
    let url: String?
    let size: CGFloat
    
    var body: some View {
        if let imageUrl = url, !imageUrl.isEmpty {
            KFImage(URL(string: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: size, height: size)
        } else {
            Image("default-avatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: size, height: size)
        }
    }
}
