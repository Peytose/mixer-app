//
//  LargeFriendsCell.swift
//  mixer
//
//  Created by Jose Martinez on 3/6/24.
//

import SwiftUI
import Kingfisher

struct LargeFriendsCell: View {
    
    let title: String
    let subtitle: String
    var imageUrl: String?
    
    init(title: String,
         subtitle: String,
         imageUrl: String? = nil){
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
    }
    
    var body: some View {
        VStack {
            AvatarView(url: imageUrl, size: DeviceTypes.ScreenSize.width * 0.25)
            
            VStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.9)
        }
    }
}
