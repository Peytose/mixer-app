//
//  HostInfoView.swift
//  mixer
//
//  Created by Jose Martinez on 3/4/23.
//

import SwiftUI
import CoreLocation
import Combine

struct HostInfoView: View {
    let host: CachedHost
    let coordinates: CLLocationCoordinate2D?
    @State var showAllEvents = false
    
    var namespace: Namespace.ID
//    @Binding var isFollowing: Bool
    @ObservedObject var viewModel: HostDetailViewModel
    @State var showMore = false
    @State var appear = [false, false, false]
    @State private var bioHeight: CGFloat = 65
    @State private var contentHeight: CGFloat = 0 // Track the actual height of the ScrollView's content view
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 10) {
                NameAndLinksRow(host: host,
                                namespace: namespace)
                
                if let bio = host.tagline {
                    Text(bio)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "bio-\(host.username)", in: namespace)
                }
                
//                FriendsWhoFollowView()
//                    .opacity(appear[0] ? 1 : 0)
            }
            
            
            if !viewModel.upcomingEvents.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        HostSubheading(text: "Upcoming Events")
                            .opacity(appear[1] ? 1 : 0)
                        
                        ForEach(showAllEvents ? viewModel.upcomingEvents : Array(viewModel.upcomingEvents.prefix(1))) { event in
                            NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event),
                                                                        namespace: namespace)) {
                                SmallEventCell(title: event.title,
                                               duration: "\(event.startDate.getTimestampString(format: "h:mm a")) - \(event.endDate.getTimestampString(format: "h:mm a"))",
                                               visibility: "\(event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false ? "Closed" : "Open") Event",
                                               dateMonth: event.startDate.getTimestampString(format: "MMM"),
                                               dateNumber: event.startDate.getTimestampString(format: "d"),
                                               imageURL: event.eventImageUrl)
                            }
                        }
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring(dampingFraction: 0.8)) {
                                    showAllEvents.toggle()
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.DesignCodeWhite)
                                        .frame(width: 350, height: 45)
                                        .overlay {
                                            Text(showAllEvents ? "Show less" : "Show all \(viewModel.upcomingEvents.count) events")
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.black)
                                        }
                                }
                            }
                            Spacer()
                        }
                        .padding(.top)
                    }
                }
            }
            
            if let description = host.description {
                VStack(alignment: .leading, spacing: 10) {
                    HostSubheading(text: "About this host")
                    
                    ScrollView {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .background(GeometryReader { geo in // Use a GeometryReader to update the height of the Text view
                                Color.clear.preference(key: ViewHeightKey.self, value: geo.size.height)
                            })
                            .onPreferenceChange(ViewHeightKey.self) { // Use onPreferenceChange to receive updates to the height of the Text view
                                contentHeight = $0
                                showMore = contentHeight > bioHeight // Update the state variable based on the new height
                            }
                    }
                    .frame(height: bioHeight) // Use the bioHeight state variable to control the height of the ScrollView's content view
                    .scrollDisabled(true)
                    
                    if showMore { // Only show the "Show more" button if the content is taller than the initial height
                        Text(contentHeight > bioHeight ? "Show less" : "Show more") // Update the text based on whether the content is currently truncated or not
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    bioHeight = contentHeight > bioHeight ? contentHeight : 65 // Update the bioHeight state variable to the appropriate value
                                }
                            }
                    }
                }
                .opacity(appear[1] ? 1 : 0)
            }
            
            if let coordinates = coordinates {
                HostSubheading(text: "Located At")
                
                MapSnapshotView(location: coordinates, host: host)
                    .cornerRadius(16)
                    .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coordinates) }
            }
            
            //MARK: Recent host events (debug report: unknown, I think it just needs a cell. However, i'm also unsure this is a navigationview.)
//            if !viewModel.recentEvents.isEmpty {
//                HostSubheading(text: "Recent Events")
//
//                ForEach(viewModel.recentEvents) { event in
//                    NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event),
//                                                                namespace: namespace)) {
//                        // Insert recent event cell here.
//                    }
//                }
//            }
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

struct ViewHeightKey: PreferenceKey { // Define a custom preference key to track the height of the Text view
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
