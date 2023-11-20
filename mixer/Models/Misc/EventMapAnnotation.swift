//
//  EventMapAnnotation.swift
//  mixer
//
//  Created by Peyton Lyons on 2/8/23.
//

import SwiftUI
import Kingfisher

struct EventMapAnnotation: View {
    let event: Event
    
    var body: some View {
        VStack {
            KFImage(URL(string: event.eventImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .background(alignment: .center) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .shadow(radius: 10)
                }
            
            Text(event.title)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
