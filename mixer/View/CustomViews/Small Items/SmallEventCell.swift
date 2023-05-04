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
                .frame(width: 70, height: 70, alignment: .leading)
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.80)
                    .multilineTextAlignment(.leading)
                
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
        SmallEventCell(title: "Phi Sig Uncaged: Black Light Party", duration: "10:00 PM - 1:00 PM", visibility: "Open Event", dateMonth: "Mar", dateNumber: "15", imageURL: "https://firebasestorage.googleapis.com:443/v0/b/mixer-firebase-project.appspot.com/o/event_images%2F7328864A-384F-4A42-A13F-EF46A3B3F309?alt=media&token=8826f13c-a038-4324-b6e6-affbd2558bff")
            .preferredColorScheme(.dark)
    }
}
