//
//  DetailRow.swift
//  mixer
//
//  Created by Jose Martinez on 1/12/23.
//

import SwiftUI
import Kingfisher

struct DetailRow: View {
    var text: String
    var imageUrl: String?
    var icon: String?
    var size: CGFloat = 20
    
    var body: some View {
        HStack {
            if let imageUrl = imageUrl {
                Color.clear
                    .frame(width: size, height: size)
                    .padding(5)
                    .background {
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .scaledToFill()
                    }
                    .cornerRadius(10)
            } else if let icon = icon {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .padding(5)
                    .background(.ultraThinMaterial)
                    .backgroundStyle(cornerRadius: 10, opacity: 0.5)
            }
            
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .fontWeight(.medium)
        }
    }
}
