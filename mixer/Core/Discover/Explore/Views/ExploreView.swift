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
    @EnvironmentObject var exploreViewModel: ExploreViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var hostManager: HostManager
    @EnvironmentObject var eventManager: EventManager
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
                            ForEach(HostManager.shared.hosts.sorted(by: { $0.name < $1.name })) { host in
                                FeaturedHostCell(host: host, namespace: namespace)
                                    .onTapGesture {
                                        homeViewModel.handleTap(to: .hostDetailView,
                                                                host: host,
                                                                hostManager: hostManager)
                                    }
                            }
                        }
                    }
                    
                    // Segmented Event Header
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section {
                            EventListView(events: exploreViewModel.separateEventsForSection(Array(eventManager.events)),
                                          hasStarted: exploreViewModel.selectedEventSection == .current,
                                          namespace: namespace,
                                          showEventView: $showEventView) { event, hasStarted, namespace in
                                EventCellView(event: event, hasStarted: hasStarted, namespace: namespace)
                                    .onTapGesture {
                                        homeViewModel.handleTap(to: .eventDetailView,
                                                                event: event,
                                                                eventManager: eventManager)
                                    }
                            }
                        } header: {
                            StickyHeaderView(items: EventSection.allCases,
                                             selectedItem: $exploreViewModel.selectedEventSection)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .padding(.top, 80)
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
