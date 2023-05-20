//
//  HostLinkIcon.swift
//  mixer
//
//  Created by Jose Martinez on 5/19/23.
//

import SwiftUI

struct HostLinkIcon: View {
    let url: String
    let icon: String
    var isAsset = false
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            if isAsset {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.white)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct HostLinkIcon_Previews: PreviewProvider {
    static var previews: some View {
        HostLinkIcon(url: "", icon: "Instagram_Glyph_Gradient 1", isAsset: true)
    }
}
