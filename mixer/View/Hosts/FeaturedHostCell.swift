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
    let host: CachedHost
    var namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                //Contains host's name, and links
                NameAndLinksRow(host: host, namespace: namespace)
                
                //MARK: Tagline
                if let tagline = host.tagline {
                    Text(tagline)
                        .subheadline(color: .white.opacity(0.8))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "bio-\(host.username)", in: namespace)
                }
            }
            //content padding
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
            //blur
            .background { backgroundBlur }
        }
        //image
        .background { backgroundImage }
        //mask to create desired rounded corners
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
            .background(Color.mixerBackground.opacity(0.2))
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .padding(-10)
            .padding(.horizontal, -15)
            .blur(radius: 30)
            .matchedGeometryEffect(id: "blur-\(host.username)", in: namespace)
    }
    var backgroundImage: some View {
        KFImage(URL(string: host.hostImageUrl))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .mask(Color.profileGradient)
            .matchedGeometryEffect(id: "image-\(host.username)", in: namespace)
    }
}

struct PlaceholderHostCard: View {
    let host: CachedHost
    var namespace: Namespace.ID
    @State var showHostView = false
    @State var isFollowing = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
//                NameAndLinksRow(host: host, isFollowing: $isFollowing, namespace: namespace)
                
                if let bio = host.tagline {
                    Text(bio)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
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
        }
        .mask {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.1, height: DeviceTypes.ScreenSize.height / 2.8)
        .padding(20)
        .preferredColorScheme(.dark)
    }
}


struct NameAndLinksRow: View {
    let host: CachedHost
    @State var showUsername = false
    @State private var timer: AnyCancellable?
    var namespace: Namespace.ID
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(showUsername ? "@\(host.username)" : "\(host.name)")
                .largeTitle()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .textSelection(.enabled)
                .matchedGeometryEffect(id: "name-\(host.username)", in: namespace)
                .onAppear {
                    timer = Timer.publish(every: Double.random(in: 3...7), on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            withAnimation(.easeInOut) {
                                self.showUsername.toggle()
                            }
                        }
                }
                .onDisappear {
                    timer?.cancel()
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        showUsername.toggle()
                    }
                }
            
            Spacer()
            
            if let handle = host.instagramHandle {
                HostLinkIcon(url: "https://instagram.com/\(handle)", icon: "Instagram_Glyph_Gradient 1", isAsset: true)
                    .matchedGeometryEffect(id: "insta-\(host.username)", in: namespace)
            }
            
            if let website = host.website {
                HostLinkIcon(url: website, icon: "globe")
                    .matchedGeometryEffect(id: "website-\(host.username)", in: namespace)
            }
        }
    }
}


struct FeaturedHostCard_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        FeaturedHostCell(host: CachedHost(from: Mockdata.host), namespace: namespace)
    }
}
