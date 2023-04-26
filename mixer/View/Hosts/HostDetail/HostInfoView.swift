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
    
    var namespace: Namespace.ID
//    @Binding var isFollowing: Bool
    @ObservedObject var viewModel: HostDetailViewModel
    @State var showMore = false
    @State var appear = [false, false, false]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 10) {
                NameAndLinksRow(host: host,
                                namespace: namespace)
                
                if let bio = host.bio {
                    Text(bio)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "bio-\(host.username)", in: namespace)
                }
                
                FriendsWhoFollowView()
                    .opacity(appear[0] ? 1 : 0)
            }
            
            
            if !viewModel.upcomingEvents.isEmpty {
                HostSubheading(text: "Upcoming Events")
                    .opacity(appear[1] ? 1 : 0)
                
                ForEach(viewModel.upcomingEvents) { event in
                    NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event),
                                                                namespace: namespace)) {
                        // Insert upcoming event cell here.
                    }
                }
            }
            
            UpcomingEventCellView(title: "Neon Party", duration: "10:00 PM - 1:00 PM", visibility: "Open Event", dateMonth: "Mar", dateNumber: "15", dateDay: "Fri")
            
            VStack(alignment: .leading, spacing: 10) {
                HostSubheading(text: "About this host")
                
                Text("Established in 1902, Theta Chi Beta Chapter is the oldest active Theta Chi chapter in the country, and is one of the first fraternities founded at MIT. We have a storied history of developing leaders: our alumni go on to start companies, build self-driving cars, cure diseases, get involved in politics, serve in the military, and change the world. The brothers of Theta Chi are dedicated to helping each other achieve their goals and give back to the community.Theta Chi is committed to fostering a fun, engaging environment built on a foundation of scholarship, love, and respect. We develop lifelong friendships that grow beyond the four short years we spend together at MIT.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(showMore ? nil : 4)
                
                Text(showMore ? "Show less" : "Show more")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showMore.toggle()
                        }
                    }
                    .padding(.top, -8)

            }
            .opacity(appear[1] ? 1 : 0)

            
            if let coordinates = coordinates {
                HostSubheading(text: "Located At")
                
                MapSnapshotView(location: coordinates, isInvited: true)
                    .cornerRadius(16)
                    .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coordinates) }
            }
            
            if !viewModel.recentEvents.isEmpty {
                HostSubheading(text: "Recent Events")
                
                ForEach(viewModel.recentEvents) { event in
                    NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event),
                                                                namespace: namespace)) {
                        // Insert recent event cell here.
                    }
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            fadeIn()
        }
    }
    
    func fadeIn() {
        withAnimation(.easeOut.delay(0.2)) {
            appear[0] = true
        }
        withAnimation(.easeOut.delay(0.3)) {
            appear[1] = true
        }
        withAnimation(.easeOut.delay(0.4)) {
            appear[2] = true
        }
    }
    
    func fadeOut() {
        appear[0] = false
        appear[1] = false
        appear[2] = false
    }
}

fileprivate struct NameAndLinksRow: View {
    let host: CachedHost
//    @Binding var isFollowing: Bool
    @State var showUsername = false
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(showUsername ? "@\(host.username)" : "\(host.name)")
                .textSelection(.enabled)
                .font(.largeTitle)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .matchedGeometryEffect(id: "name-\(host.username)", in: namespace)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        showUsername.toggle()
                    }
                }
            
            HStack(alignment: .center, spacing: 10) {
                Text("@\(host.username)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .matchedGeometryEffect(id: "username-\(host.username)", in: namespace)
                
                
                Spacer()
                
                if let handle = host.instagramHandle {
                    HostLinkIcon(url: "https://instagram.com/\(handle)", icon: "Instagram_Glyph_Gradient 1", isAsset: true)
                        .matchedGeometryEffect(id: "insta-\(host.username)", in: namespace)
                }

                if let website = host.website {
                    HostLinkIcon(url: website, icon: "globe")
                        .matchedGeometryEffect(id: "website-\(host.username)", in: namespace)
                }
                
                //MARK: Follow button (debug report: This file is irrelevant, needs to merge with other NameAndLinksRow)
//                Text(isFollowing ? "Following" : "Follow")
//                    .font(.footnote.weight(.semibold))
//                    .foregroundColor(isFollowing ? .white : .black)
//                    .padding(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
//                    .background {
//                        if isFollowing {
//                            Capsule()
//                                .stroke()
//                                .matchedGeometryEffect(id: "hostFollowButton-\(host.username)", in: namespace)
//                        } else {
//                            Capsule()
//                                .matchedGeometryEffect(id: "hostFollowButton-\(host.username)", in: namespace)
//                        }
//
//                    }
//                    .onTapGesture {
//                        let impact = UIImpactFeedbackGenerator(style: .light)
//                        impact.impactOccurred()
//                        withAnimation(.follow) {
//                            isFollowing.toggle()
//                        }
//                    }
//                    .matchedGeometryEffect(id: "follow-button-\(host.username)", in: namespace)
            }
        }
    }
}

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
                    .foregroundColor(Color.mainFont)
                    .frame(width: 24, height: 24)
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
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
                Image("mock-user-1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
                Circle()
                    .fill(Color.mixerSecondaryBackground)
                    .frame(width: 30, height: 30)
                    .overlay(alignment: .center) {
                        Text("+3")
                            .foregroundColor(.white)
                            .font(.footnote)
                    }
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 3) {
                    Text("Followed by")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("peytonlyons2002, fishcoop, jose")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                }
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                
                Text("and 3 more")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}
