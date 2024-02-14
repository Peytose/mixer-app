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
    var isUniversity: Bool = false
    
    var body: some View {
        HStack {
            if let imageUrl = imageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: "\(isUniversity ? "graduationcap" : "mappin").circle.fill" )
                    .resizable()
                    .foregroundColor(Color.theme.mixerIndigo)
                    .tint(.white)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .foregroundColor(.white)
                
                Text("\(type == SearchType.hosts || type == SearchType.users ? "@" : "")\(subtitle)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .padding(.leading, 8)
        }
    }
}