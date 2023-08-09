//
//  ExploreView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import FirebaseFirestore

struct ExploreView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var homeViewModel: HomeViewModel
    @StateObject var exploreViewModel = ExploreViewModel()
    @State var showHostView = false
    @State var showEventView = false
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    // Featured Hosts Section
                    VStack(spacing: 10) {
                        Text("Featured Hosts")
                            .largeTitle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .opacity(showHostView ? 0 : 1)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            ForEach(homeViewModel.hosts.sorted(by: { $0.name < $1.name })) { host in
                                FeaturedHostCell(host: host, namespace: namespace)
                                    .onTapGesture {
                                        homeViewModel.selectedHost = host
                                    }
                            }
                        }
                    }
                    
                    // Segmented Event Header
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section(header: exploreViewModel.stickyHeader()) {
                            EventListView(events: exploreViewModel.separateEventsForSection(Array(homeViewModel.events)),
                                          hasStarted: exploreViewModel.eventSection == .current,
                                          namespace: namespace,
                                          selectedEvent: $homeViewModel.selectedEvent,
                                          showEventView: $showEventView) { event, hasStarted, namespace in
                                EventCellView(event: event, hasStarted: hasStarted, namespace: namespace)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if homeViewModel.hosts.isEmpty {
                homeViewModel.fetchHosts()
            }
            
            if homeViewModel.events.isEmpty {
                homeViewModel.fetchEvents()
            }
        }
    }
}

//fileprivate struct RefreshButton: View {
//    @Binding var isRefreshing: Bool
//    let action: () -> Void
//
//    var body: some View {
//        HStack {
//            Spacer()
//
//            Button {
//                let impact = UIImpactFeedbackGenerator(style: .light)
//                impact.impactOccurred()
//
//                withAnimation(.spring(response: 2.2)) { action() }
//            } label: {
//                ZStack {
//                    Circle()
//                        .fill(.ultraThinMaterial.opacity(0.9))
//                        .backgroundColor(opacity: 0.4)
//                        .backgroundBlur(radius: 10)
//
//                    Image(systemName: "arrow.triangle.2.circlepath")
//                        .resizable()
//                        .scaledToFill()
//                        .imageScale(.large)
//                        .fontWeight(.medium)
//                        .foregroundColor(.white)
//                        .frame(width: 25, height: 25)
//                }
//                .rotationEffect(Angle(degrees: isRefreshing ? 720 : 0))
//                .frame(width: 45, height: 45)
//            }
//        }
//        .padding(.trailing)
//    }
//}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExploreView()
        }
    }
}
