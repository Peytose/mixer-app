//
//  SearchResultsCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/1/23.
//

import SwiftUI
import Kingfisher

struct SearchResultsCell: View {
    var imageUrl: String?
    let title: String
    let subtitle: String
    var type: SearchType?
    
    var body: some View {
        HStack {
            if let imageUrl = imageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
            } else {
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .foregroundColor(Color.theme.mixerIndigo)
                    .tint(.white)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Text("\(type == SearchType.hosts || type == SearchType.users ? "@" : "")\(subtitle)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .padding(.bottom, 8)
                
                Divider()
            }
            .padding(.leading, 8)
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
    }
}
