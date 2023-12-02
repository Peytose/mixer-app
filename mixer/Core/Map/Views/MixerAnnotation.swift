//
//  MixerAnnotation.swift
//  mixer
//
//  Created by Peyton Lyons on 11/29/23.
//

import SwiftUI
import Kingfisher

struct MixerAnnotation: View {
    
    var item: MixerMapItem
    var number: Int
    
    var body: some View {
        VStack {
            ZStack {
                MapBalloon()
                    .fill(Color.white)
                    .frame(width: 51, height: 60.71429443359375)
                
                KFImage(URL(string: item.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .offset(y: -5)
                    .overlay(alignment: .bottom) {
                        CustomBadgeModifier(value: .constant(number))
                    }
            }
            
            Text(item.title)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct MixerAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        MixerAnnotation(item: MixerMapItem(host: dev.mockHost), number: 1)
    }
}
