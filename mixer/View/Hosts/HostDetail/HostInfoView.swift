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
    
    var namespace: Namespace.ID
    @ObservedObject var viewModel: HostDetailViewModel
    @State var showAllEvents = false
    @State var showMore = false
    @State var appear = [false, false, false]
    @State private var bioHeight: CGFloat = 65
    @State private var contentHeight: CGFloat = 0 // Track the actual height of the ScrollView's content view
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Host name, links and tagline section
            nameAndTagline
                .unredacted()
                .padding(.bottom, 8)
            
            // Upcoming events section
            ZStack {
                if !viewModel.upcomingEvents.isEmpty {
                    upcomingEvents
                }
            }
            .opacity(appear[0] ? 1 : 0)

            hostDescription
                .opacity(appear[1] ? 1 : 0)
            
            // Map section
            VStack {
                mapSection
            }
            .opacity(appear[2] ? 1 : 0)

        }
        .padding(.horizontal)
        // Trigger the staggered fade in animation
        .onAppear {
            fadeIn()
        }
    }
}

extension HostInfoView {
    var nameAndTagline: some View {
        VStack(alignment: .leading, spacing: 8) {
            NameAndLinksRow(host: viewModel.host,
                            namespace: namespace)
            
            // MARK: Tagline
            if let tagline = viewModel.host.tagline {
                Text(tagline)
                    .subheadline(color: .white.opacity(0.8))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .matchedGeometryEffect(id: "bio-\(viewModel.host.username)", in: namespace)
            }
        }
    }
    
    var upcomingEvents: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Upcoming Events")
                    .primaryHeading()
                
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
                
                if viewModel.upcomingEvents.count > 1 {
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
                    .padding(.top, 8)
                }
            }
        }
    }
    
    @ViewBuilder
    var hostDescription: some View {
        if let description = viewModel.host.description {
            VStack(alignment: .leading, spacing: 4) {
                Text("About this host")
                    .primaryHeading()
                
                ScrollView {
                    Text(description)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        }
    }
    
    @ViewBuilder
    var mapSection: some View {
        if let coordinates = viewModel.coordinates {
            VStack(alignment: .leading, spacing: 8) {
                Text("Located At")
                    .primaryHeading()
                
                VStack(alignment: .leading, spacing: 4) {
                    MapSnapshotView(location: coordinates, host: viewModel.host)
                        .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coordinates) }
                    
                    Text("Tap the map for directions to this host!")
                        .footnote()
                }
            }
        }
    }
    
    //MARK: Fade-in Functions
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
}

struct ViewHeightKey: PreferenceKey { // Define a custom preference key to track the height of the Text view
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct HostInfoView_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        HostInfoView(namespace: namespace, viewModel: HostDetailViewModel(host: CachedHost(from: Mockdata.host)))
            .preferredColorScheme(.dark)
    }
}
