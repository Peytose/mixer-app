//
//  ExploreView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import TabBar
import FirebaseFirestore

struct ExploreView: View {
    @ObservedObject var viewModel = ExploreViewModel()
    @State var selectedHost: CachedHost?
    @State var selectedEvent: CachedEvent?
    @State var showHostView = false
    @State var showEventView = false
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Featured Hosts Section
                    Text("Featured Hosts")
                        .font(.largeTitle.weight(.bold))
                        .padding(.leading)
                        .padding(.top, 70)
                        .opacity(showHostView ? 0 : 1)
                        .animation(.none)
                        .zIndex(0)
                
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.hosts) { host in
                                
                                if !showHostView {
                                    FeaturedHostCell(host: host, namespace: namespace)
                                        .onTapGesture {
                                            withAnimation(.openCard) {
                                                self.selectedHost = host
                                                self.showHostView = true
                                            }
                                        }
                                        .zIndex(2)
                                } else {
                                    PlaceholderHostCard(host: host, namespace: namespace)
                                        .opacity(0)
                                }
                            }
                        }
                    }
                    
                    // Segmented Event Header
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section(header: viewModel.stickyHeader()) {
                            EventListView(events: viewModel.eventSection == .today ? viewModel.todayEvents : viewModel.futureEvents,
                                          hasStarted: viewModel.eventSection == .today,
                                          namespace: namespace,
                                          selectedEvent: $selectedEvent,
                                          showEventView: $showEventView) { event, hasStarted, namespace in
                                EventCellView(event: event, hasStarted: hasStarted, namespace: namespace)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .refreshable { viewModel.refresh() }
            
            if let host = selectedHost, showHostView {
                HostDetailView(viewModel: HostDetailViewModel(host: host),
                               namespace: namespace)
                .zIndex(2)
                .transition(.asymmetric(
                    insertion: .opacity.animation(.easeInOut(duration: 0.1)),
                    removal: .opacity.animation(.easeInOut(duration: 0.3).delay(0.2))))
                .overlay(alignment: .topTrailing) {
                    XDismissButton()
                        .onTapGesture {
                            withAnimation(.closeCard) {
                                self.showHostView = false
                                self.selectedHost = nil
                            }
                        }
                    
                        .padding(20)
                }
            }
            
            if let event = selectedEvent, showEventView {
                EventDetailView(viewModel: EventDetailViewModel(event: event),
                              namespace: namespace)
                .overlay(alignment: .topTrailing) {
                    XDismissButton()
                        .padding(.top, 50)
                        .padding(.trailing, 30)
                        .onTapGesture {
                            withAnimation(.closeCard) {
                                self.showEventView = false
                                self.selectedEvent = nil
                            }
                        }
                }
            }
        }
        .task {
            viewModel.getHosts()
            viewModel.getTodayEvents()
            viewModel.getFutureEvents()
        }
        .ignoresSafeArea()
        .background(Color.mixerBackground)
        .preferredColorScheme(.dark)
        .statusBar(hidden: showHostView)
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
