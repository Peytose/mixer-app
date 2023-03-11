//
//  HostInfoView.swift
//  mixer
//
//  Created by Jose Martinez on 3/4/23.
//

import SwiftUI
import CoreLocation

struct HostInfoView: View {
    let host: CachedHost
    let coordinates: CLLocationCoordinate2D?
    let namespace: Namespace.ID
    @Binding var isFollowing: Bool
    @ObservedObject var viewModel: HostDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NameAndLinksRow(host: host,
                            handle: host.instagramHandle,
                            website: host.website,
                            isFollowing: $isFollowing,
                            namespace: namespace)
            
            Divider()
            
            if let bio = host.bio {
                Text(bio)
                    .font(.subheadline.weight(.regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.top, 5)
                    .matchedGeometryEffect(id: "bio", in: namespace)
            }
            
            Divider()
            
            FriendsWhoFollowView()
            
            Divider()
            
            if !viewModel.upcomingEvents.isEmpty {
                VStack(alignment: .leading) {
                    HostSubheading(text: "Upcoming Events")
                    
                    ForEach(viewModel.upcomingEvents) { event in
                        NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event),
                                                                    namespace: namespace)) {
                            // Insert upcoming event cell here.
                        }
                    }
                }
                
                Divider()
            }
            
            if let coordinates = coordinates {
                VStack(alignment: .leading) {
                    HostSubheading(text: "Located At")
                    
                    MapSnapshotView(location: coordinates, isInvited: true)
                        .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coordinates) }
                }
                
                Divider()
            }
            
            if !viewModel.recentEvents.isEmpty {
                VStack(alignment: .leading) {
                    HostSubheading(text: "Recent Events")
                    
                    ForEach(viewModel.recentEvents) { event in
                        NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event),
                                                                    namespace: namespace)) {
                            // Insert recent event cell here.
                        }
                    }
                }
                
                Divider()
            }
        }
        .padding(.horizontal)
    }
}

fileprivate struct NameAndLinksRow: View {
    let host: CachedHost
    var handle: String?
    var website: String?
    @Binding var isFollowing: Bool
    @State var showUsername = false
    let namespace: Namespace.ID
    
    var body: some View {
        HStack(alignment: .center) {
            Text(showUsername ? "@\(host.username)" : "\(host.name)")
                .textSelection(.enabled)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .matchedGeometryEffect(id: "name", in: namespace)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        showUsername.toggle()
                    }
                }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 13) {
                Image(systemName: isFollowing ? "checkmark.circle" : "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.mainFont)
                    .frame(width: 26, height: 26)
                    .rotationEffect(Angle(degrees: isFollowing ? 360 : 0))
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.follow) {
                            isFollowing.toggle()
                        }
                    }
                
                if let handle = handle {
                    HostLinkIcon(url: "https://instagram.com/\(handle)", icon: "Instagram_Glyph_Gradient 1", isAsset: true)
                }
                
                if let website = website {
                    HostLinkIcon(url: website, icon: "globe")
                }
            }
        }
    }
}

fileprivate struct HostLinkIcon: View {
    let url: String
    let icon: String
    var isAsset = false
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            if isAsset {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            } else {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.mainFont)
                    .frame(width: 25, height: 25)
            }
        }
    }
}

fileprivate struct FriendsWhoFollowView: View {
    
    var body: some View {
        HStack {
            HStack(spacing: -8) {
                Image("profile-banner-1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                
                Image("mock-user-1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                
                Circle()
                    .fill(Color.mixerSecondaryBackground)
                    .frame(width: 28, height: 28)
                    .overlay(alignment: .center) {
                        Text("+3")
                            .foregroundColor(.white)
                            .font(.footnote)
                    }
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 3) {
                    Text("Followed by")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("peytonlyons2002, fishcoop")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                
                Text("and 3 more")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
