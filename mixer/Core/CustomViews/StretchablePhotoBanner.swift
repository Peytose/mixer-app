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
                .mask(Color.theme.profileGradient) // mask the blurred image using the gradient's alpha values
                .offset(y: scrollY > 0 ? -scrollY : 0)
                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}

struct EventPhotoBanner: View {
    let imageUrl: String
    var namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            ZStack {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.size.width,
                           height: DeviceTypes.ScreenSize.height / 2)
                    .mask(Color.theme.profileGradient)
                    .offset(y: scrollY > 0 ? -scrollY : 0)
                    .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                    .blur(radius: scrollY > 0 ? scrollY / 20 : 0)
                    .opacity(0.9)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .backgroundBlur(radius: 10, opaque: true)
                    .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.size.width,
                           height: DeviceTypes.ScreenSize.height)
                    .mask(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: proxy.size.width - 40,
                                   height: proxy.size.height)
                    )
                    .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                    .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width,
                                                                height: proxy.size.height)))
                    .zIndex(2)
            }
        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct HostBannerView: View {
    let host: Host
    var namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height * 0.4)
                .mask(Color.theme.profileGradient) // mask the blurred image using the gradient's alpha values
                .offset(y: scrollY > 0 ? -scrollY : 0)
                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                .blur(radius: scrollY > 0 ? scrollY / 40 : 0)
                .matchedGeometryEffect(id: "image-\(host.username)",
                                       in: namespace)
                .mask {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .matchedGeometryEffect(id: "corner-mask-\(host.username)",
                                               in: namespace)
                }
        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}
