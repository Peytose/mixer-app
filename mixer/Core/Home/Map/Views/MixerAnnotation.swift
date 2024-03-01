//
//  MixerAnnotation.swift
//  mixer
//
//  Created by Peyton Lyons on 11/29/23.
//

import SwiftUI
import Kingfisher

struct MixerAnnotation: View {
    
    @ObservedObject var viewModel: MapViewModel
    var index: Int
    
    private var eventCountBinding: Binding<Int> {
        Binding<Int>(
            get: { self.viewModel.hostEventCounts[self.viewModel.mapItems[index].id ?? ""] ?? 0 },
            set: { self.viewModel.hostEventCounts[self.viewModel.mapItems[index].id ?? ""] = $0 }
        )
    }
    
    var body: some View {
        VStack {
            ZStack {
                MapBalloon()
                    .fill(Color.white)
                    .frame(width: 51, height: 60.71429443359375)
                
                KFImage(URL(string: self.viewModel.mapItems[index].imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .offset(y: -5)
                    .overlay(alignment: .bottom) {
                        CustomBadgeModifier(value: eventCountBinding,
                                            x: 40.0,
                                            y: 0.0)
                    }
            }
            
            Text(self.viewModel.mapItems[index].title)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
