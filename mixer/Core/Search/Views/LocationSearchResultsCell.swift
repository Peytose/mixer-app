//
//  LocationSearchResultsCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/1/23.
//

import SwiftUI
import Kingfisher

struct LocationSearchResultsCell: View {
    let location: MixerLocation
    
    var body: some View {
        HStack {
            KFImage(URL(string: location.imageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Text(location.subtitle)
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

struct LocationSearchResultsCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchResultsCell(location: MixerLocation(host: dev.mockHost))
    }
}
