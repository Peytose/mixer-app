//
//  StretchablePhotoBanner.swift
//  mixer
//
//  Created by Peyton Lyons on 1/28/23.
//

import SwiftUI
import Kingfisher

struct StretchablePhotoBanner: View {
    let imageUrl: String
    var namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width, height: DeviceTypes.ScreenSize.height / 2.3)
                .mask(Color.profileGradient) // mask the blurred image using the gradient's alpha values
                .offset(y: scrollY > 0 ? -scrollY : 0)
                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
//                .blur(radius: scrollY > 0 ? scrollY / 40 : 0)
            
        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}

struct HostBannerView: View {
    let host: CachedHost
    var namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width, height: DeviceTypes.ScreenSize.height / 2.3)
                .mask(Color.profileGradient) // mask the blurred image using the gradient's alpha values
                .offset(y: scrollY > 0 ? -scrollY : 0)
                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                .blur(radius: scrollY > 0 ? scrollY / 40 : 0)
                .matchedGeometryEffect(id: "blur-\(host.username)", in: namespace)
                .matchedGeometryEffect(id: "image-\(host.username)", in: namespace)
                .mask {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .matchedGeometryEffect(id: "corner-mask-\(host.username)", in: namespace)
                }

        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}
