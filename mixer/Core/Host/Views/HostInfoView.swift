//
//  HostInfoView.swift
//  mixer
//
//  Created by Jose Martinez on 3/4/23.
//

import SwiftUI
import Firebase
import CoreLocation
import Combine

struct HostInfoView: View {
    @State private var bioHeight: CGFloat = 65
    @State private var contentHeight: CGFloat = 0
    var namespace: Namespace.ID
    @State private var showMoreEvents = false
    @EnvironmentObject var viewModel: HostViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Host name, links and tagline section
            NameAndTaglineView(namespace: namespace)
//                .padding(.bottom, 8)
            
            // Upcoming events section
            if !viewModel.currentAndFutureEvents.filter({ $0.startDate > Timestamp() }).isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upcoming Events")
                            .primaryHeading()
                        
                        ForEach(showMoreEvents ? viewModel.currentAndFutureEvents : Array(viewModel.currentAndFutureEvents.prefix(1))) { event in
                            NavigationLink {
                                EventDetailView(namespace: namespace)
                                .environmentObject(EventViewModel(event: event))
                            } label: {
                                SmallEventCell(title: event.title,
                                               duration: "\(event.startDate.getTimestampString(format: "h:mm a")) - \(event.endDate.getTimestampString(format: "h:mm a"))",
                                               visibility: "\(event.isInviteOnly ? "Closed" : "Open") Event",
                                               dateMonth: event.startDate.getTimestampString(format: "MMM"),
                                               dateNumber: event.startDate.getTimestampString(format: "d"),
                                               imageURL: event.eventImageUrl)
                            }
                        }
                        
                        let numOfEvents = viewModel.currentAndFutureEvents.count
                        if numOfEvents > 1 {
                            ShowMoreEventsButton(showMoreEvents: $showMoreEvents,
                                                 numOfEvents: numOfEvents)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            
            // Host description
            VStack(alignment: .leading, spacing: 4) {
                Text("About this host")
                    .primaryHeading()
                
                Text(viewModel.host.description)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Map section
            let location = CLLocationCoordinate2D(latitude: viewModel.host.location.latitude,
                                                  longitude: viewModel.host.location.longitude)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Located At")
                    .primaryHeading()
                
                VStack(alignment: .leading, spacing: 4) {
                    MapSnapshotView(location: .constant(location))
                    .onTapGesture { viewModel.getDirectionsToLocation(coordinates: location) }
                    
                    Text("Tap the map for directions to this host!")
                        .footnote()
                }
            }
        }
        .padding(.horizontal)
    }
}

fileprivate struct NameAndTaglineView: View {
    var namespace: Namespace.ID
    @EnvironmentObject var viewModel: HostViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NameAndLinksRow(host: viewModel.host, namespace: namespace)
            
            if let tagline = viewModel.host.tagline {
                Text(tagline)
                    .subheadline(color: .white.opacity(0.8))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .matchedGeometryEffect(id: "tagline-\(viewModel.host.username)", in: namespace)
            }
        }
    }
}

fileprivate struct ShowMoreEventsButton: View {
    @Binding var showMoreEvents: Bool
    let numOfEvents: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                withAnimation(.spring(dampingFraction: 0.8)) {
                    showMoreEvents.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.white)
                        .frame(width: 350, height: 45)
                        .overlay {
                            Text(showMoreEvents ? "Show less" : "Show all \(numOfEvents) events")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                        }
                }
            }
            
            Spacer()
        }
    }
}

struct ViewHeightKey: PreferenceKey { // Define a custom preference key to track the height of the Text view
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

//struct HostInfoView_Previews: PreviewProvider {
//    @Namespace static var namespace
//
//    static var previews: some View {
//        HostInfoView(namespace: namespace, viewModel: HostDetailViewModel(host: Host(from: Mockdata.host)))
//            .preferredColorScheme(.dark)
//    }
//}
