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
        HStack(spacing: 5) {
            KFImage(URL(string: imageURL))
//            Image("theta-chi-party-poster")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80, alignment: .leading)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(dateMonth) ")
                    
                    + Text(dateNumber)
                    
                    Text(duration)
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                
                Text(title)
                    .font(.title3.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                
                Text(visibility)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                
            }
            .padding(.horizontal, 10)
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
