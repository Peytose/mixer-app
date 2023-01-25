//
//  FeaturedHostCard.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI

struct FeaturedHost: View {
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Spacer()
            
            Button(action: {}) {
//                Image(uiImage: host.universityImage)
                Image("2560px-MIT_logo.svg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .cornerRadius(10)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .modifier(OutlineOverlay(cornerRadius: 18))
            }
            
//            Text(host.name)
            Text("Theta Chi")
                .font(.title).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
//            Text(host.address.uppercased())
            Text("528 Beacon St")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            
//            Text(host.description)
            Text("Some say the best fraternity at MIT. Theta Chi parties are a must visit in the boston college scene")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(.ultraThinMaterial)
        .backgroundColor(opacity: 0.5)
        .preferredColorScheme(.dark)
    }
}

struct FeaturedHost_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedHost()
    }
}
