//
//  FeaturedHostCell.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import Kingfisher
import Combine

struct FeaturedHostCell: View {
    let host: Host
    var namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                NameAndLinksRow(host: host, namespace: namespace)
                
                Text(host.tagline ?? "")
                    .subheadline(color: .white.opacity(0.8))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .matchedGeometryEffect(id: "tagline-\(host.username)", in: namespace)
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
            .background(backgroundBlur)
        }
        .background(backgroundImage)
        .mask {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .matchedGeometryEffect(id: "corner-mask-\(host.username)", in: namespace)
        }
        .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: DeviceTypes.ScreenSize.height * 0.35)
        .padding(20)
        .preferredColorScheme(.dark)
    }
}

extension FeaturedHostCell {
    var backgroundBlur: some View {
        Rectangle()
            .fill(.ultraThinMaterial.opacity(0.8))
            .background(Color.theme.backgroundColor.opacity(0.2))
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .padding(-10)
            .padding(.horizontal, -15)
            .blur(radius: 30)
            .matchedGeometryEffect(id: "blur-\(namespace)", in: namespace)
    }
    
    var backgroundImage: some View {
        KFImage(URL(string: host.hostImageUrl))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .mask(Color.theme.profileGradient)
            .matchedGeometryEffect(id: "image-\(host.username)", in: namespace)
    }
}

struct FeaturedHostCard_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        FeaturedHostCell(host: dev.mockHost, namespace: namespace)
    }
}
