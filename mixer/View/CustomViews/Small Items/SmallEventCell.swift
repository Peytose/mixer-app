//
//  SmallEventCell.swift
//  mixer
//
//  Created by Jose Martinez on 5/3/23.
//

import SwiftUI
import Kingfisher

struct SmallEventCell: View {
    var title: String
    var duration: String
    var visibility: String
    var dateMonth: String
    var dateNumber: String
    var imageURL: String
    
    var body: some View {
        HStack(spacing: 0) {
            KFImage(URL(string: imageURL))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .frame(width: 100, height: 80, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(dateMonth) ")
                    
                    + Text(dateNumber)
                    
                    Text(duration)
                        .foregroundColor(.secondary)
                }
                .font(.callout)
                .fontWeight(.medium)
                
                Text(title)
                    .font(.title2.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                
                Text(visibility)
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondary)
                
            }
            .padding(.trailing, 10)
        }
        .frame(maxHeight: 150, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mixerSecondaryBackground)
        .cornerRadius(16)
        .padding(.horizontal)
        .foregroundColor(.white)
    }
}

struct SmallEventCell_Previews: PreviewProvider {
    static var previews: some View {
        SmallEventCell(title: "Neon Party", duration: "10:00 PM - 1:00 PM", visibility: "Open Event", dateMonth: "Mar", dateNumber: "15", imageURL: "")
            .preferredColorScheme(.dark)
    }
}
