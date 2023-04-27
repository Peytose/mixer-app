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
    @State var showHostView = false
    @State var isFollowing = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                NameAndLinksRow(host: host, namespace: namespace)
                
                if let bio = host.bio {
                    Text(bio)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "bio-\(host.username)", in: namespace)
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
                    .matchedGeometryEffect(id: "blur-\(host.username)", in: namespace)
            }
        }
        .foregroundStyle(.white)
        .background {
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .mask(Color.profileGradient)
                .matchedGeometryEffect(id: "image-\(host.username)", in: namespace)
        }
        .mask {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .matchedGeometryEffect(id: "corner-mask-\(host.username)", in: namespace)
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.1, height: DeviceTypes.ScreenSize.height / 2.8)
        .padding(20)
        .preferredColorScheme(.dark)
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
                
                if let bio = host.bio {
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
//    @Binding var isFollowing: Bool
    @State var showUsername = false
    @State private var timer: AnyCancellable?
    var namespace: Namespace.ID
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(showUsername ? "@\(host.username)" : "\(host.name)")
                .textSelection(.enabled)
                .font(.largeTitle)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .matchedGeometryEffect(id: "name-\(host.username)", in: namespace)
                .onAppear {
                    timer = Timer.publish(every: Double.random(in: 1...5), on: .main, in: .common)
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
            
            //MARK: Follow button (bug report: doesn't update after pressing and redirecting)
//            Text(isFollowing ? "Following" : "Follow")
//                .font(.footnote.weight(.semibold))
//                .foregroundColor(isFollowing ? .white : .black)
//                .padding(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
//                .background {
//                    if isFollowing {
//                        Capsule()
//                            .stroke()
//                            .matchedGeometryEffect(id: "hostFollowButton-\(host.username)", in: namespace)
//                    } else {
//                        Capsule()
//                            .matchedGeometryEffect(id: "hostFollowButton-\(host.username)", in: namespace)
//                    }
//
//                }
//                .onTapGesture {
//                    let impact = UIImpactFeedbackGenerator(style: .light)
//                    impact.impactOccurred()
//                    withAnimation(.follow) {
//                        isFollowing.toggle()
//                    }
//                }
//                .matchedGeometryEffect(id: "follow-button-\(host.username)", in: namespace)
        }
    }
}


struct FeaturedHostCard_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        FeaturedHostCell(host: CachedHost(from: Mockdata.host), namespace: namespace)
    }
}
