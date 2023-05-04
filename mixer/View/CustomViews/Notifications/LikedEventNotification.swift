//
//  LikedEventNotification.swift
//  mixer
//
//  Created by Jose Martinez on 5/3/23.
//

import SwiftUI

struct LikedEventNotification: View {
    let title: String
    let text: String
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.semibold)
                    
                    Text(text)
                }
                .font(.subheadline)
                .lineLimit(1)
            }
            .frame(width: DeviceTypes.ScreenSize.width - 60, height: 60, alignment: .leading)
        }
        .frame(width: DeviceTypes.ScreenSize.width - 20, height: 60)
        .background(Color.mixerSecondaryBackground)
        .cornerRadius(24)
    }
}

struct LikedEventNotification_Previews: PreviewProvider {
    static var previews: some View {
        LikedEventNotification(title: "MIT SHPE 2023 Gala Gigante", text: "has been removed from your liked events")
            .preferredColorScheme(.dark)
    }
}
