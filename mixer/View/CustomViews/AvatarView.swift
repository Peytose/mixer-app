//
//  AvatarView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI

struct AvatarView: View {
    var image: UIImage
    var size: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .shadow(radius: 20)
            .background(Circle().fill(.ultraThinMaterial))
            .frame(width: size, height: size)
    }
}

//struct AvatarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AvatarView(image: PlaceholderImage.avatar, size: 90)
//    }
//}
