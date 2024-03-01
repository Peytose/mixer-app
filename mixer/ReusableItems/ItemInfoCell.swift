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
    var university: University?
    var icon: String?
    var content: Content?
    
    init(title: String,
         subtitle: String,
         imageUrl: String? = nil,
         university: University? = nil,
         icon: String? = nil,
         @ViewBuilder content: () -> Content? = { nil }) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.university = university
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
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.callout)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                    
                }
                .padding(.leading, 8)
                
                Spacer()
                
                if let university = university {
                    HStack(spacing: 2) {
                        Image(systemName: "graduationcap.fill")

                        Text(university.shortName ?? university.name)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let content = content {
                content
            }
        }
        .contentShape(Rectangle())
    }
}

extension ItemInfoCell where Content == EmptyView {
    init(title: String,
         subtitle: String,
         imageUrl: String? = nil,
         university: University? = nil,
         icon: String? = nil) {
      self.init(title: title,
                subtitle: subtitle,
                imageUrl: imageUrl,
                university: university,
                icon: icon,
                content: { EmptyView() })
  }
}
