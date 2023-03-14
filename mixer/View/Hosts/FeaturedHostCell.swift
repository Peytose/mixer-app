//
//  FeaturedHostCell.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import Kingfisher

struct FeaturedHostCell: View {
    let host: CachedHost
    var namespace: Namespace.ID
    @State var showHostView = false
    @State var isFollowing = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(host.name)
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .matchedGeometryEffect(id: host.name, in: namespace)
                    
                    HStack {
                        Text("@\(host.username)")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .matchedGeometryEffect(id: host.username, in: namespace)
                        
                        Spacer()
                        
//                        Text(isFollowing ? "Following" : "Follow")
//                            .font(.footnote.weight(.semibold))
//                            .foregroundColor(isFollowing ? .white : .black)
//                            .padding(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
//                            .background {
//                                if isFollowing {
//                                    Capsule()
//                                        .stroke()
//                                } else {
//                                    Capsule()
//                                }
//
//                            }
//                            .onTapGesture {
//                                let impact = UIImpactFeedbackGenerator(style: .light)
//                                impact.impactOccurred()
//                                withAnimation(.follow) {
//                                    isFollowing.toggle()
//                                }
//                            }
//                            .matchedGeometryEffect(id: "follow\(host.id)", in: namespace)
                        
                    }
                }
                
                if let bio = host.bio {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "\(host.name)-bio", in: namespace)
                }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.8))
                    .background(Color.mixerBackground.opacity(0.2))
                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(-10)
                    .padding(.horizontal, -15)
                    .blur(radius: 30)
            }
        }
        .foregroundStyle(.white)
        .background {
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .mask(Color.profileGradient)
                .matchedGeometryEffect(id: host.hostImageUrl, in: namespace)
        }
        .mask {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.1, height: DeviceTypes.ScreenSize.height / 2.8)
        .preferredColorScheme(.dark)
    }
}

struct FeaturedHostCard_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        FeaturedHostCell(host: CachedHost(from: Mockdata.host), namespace: namespace)
    }
}
