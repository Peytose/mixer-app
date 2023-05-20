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
        HStack {
            Image(systemName: "list.bullet.clipboard")
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                
                Text(text)
            }
            .font(.subheadline)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .notificationContentFrame()
        .notificationBackground()
    }
}

struct LikedEventNotification_Previews: PreviewProvider {
    static var previews: some View {
        LikedEventNotification(title: "MIT SHPE 2023 Gala Gigante", text: "has been removed from your liked events")
            .preferredColorScheme(.dark)
    }
}
