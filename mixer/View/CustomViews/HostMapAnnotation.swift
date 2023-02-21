//
//  HostMapAnnotation.swift
//  mixer
//
//  Created by Peyton Lyons on 2/8/23.
//

import SwiftUI
import Kingfisher

struct HostMapAnnotation: View {
    var host: CachedHost
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.mixerIndigo)
                
                KFImage(URL(string: host.hostImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            
            Text(host.name)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
