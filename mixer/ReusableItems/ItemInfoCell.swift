//
//  ItemInfoCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/1/23.
//

import SwiftUI
import Kingfisher

struct ItemInfoCell<Content: View>: View {
    
    let title: String
    let subtitle: String
    var imageUrl: String?
    var icon: String?
    var content: Content?
    
    init(title: String, subtitle: String, imageUrl: String? = nil, icon: String? = nil, @ViewBuilder content: () -> Content? = { nil }) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        HStack {
            if let imageUrl = imageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
            } else if let icon = icon {
                Image(systemName: icon)
                    .resizable()
                    .foregroundColor(Color.theme.mixerIndigo)
                    .tint(.white)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            if let content = content {
                content
            }
        }
    }
}

extension ItemInfoCell where Content == EmptyView {
  init(title: String, subtitle: String, imageUrl: String? = nil, icon: String? = nil) {
      self.init(title: title,
                subtitle: subtitle,
                imageUrl: imageUrl,
                icon: icon,
                content: { EmptyView() })
  }
}
