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
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.hosts) { host in
                                FeaturedHostCell(host: host, namespace: namespace)
                                    .onTapGesture {
                                        withAnimation(.openCard) {
                                            self.selectedHost = host
                                            self.showHostView = true
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Segmented Event Header
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section {
                            if viewModel.eventSection == .today {
                                EventListView(events: viewModel.todayEvents,
                                              hasStarted: true,
                                              namespace: namespace,
                                              selectedEvent: $selectedEvent,
                                              showEventView: $showEventView)
                            } else if viewModel.eventSection == .future {
                                EventListView(events: viewModel.futureEvents,
                                              hasStarted: false,
                                              namespace: namespace,
                                              selectedEvent: $selectedEvent,
                                              showEventView: $showEventView)
                            }
                        } header: {
                            viewModel.stickyHeader()
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .refreshable { viewModel.refresh() }
            
            if let host = selectedHost, showHostView {
                HostDetailView(viewModel: HostDetailViewModel(host: host),
                               namespace: namespace)
                .toolbar {
                    XDismissButton()
                        .onTapGesture {
                            withAnimation(.closeCard) {
                                self.showHostView = false
                                self.selectedHost = nil
                            }
                        }
                }
            }
            
            if let event = selectedEvent, showEventView {
                EventDetailView(viewModel: EventDetailViewModel(event: event),
                                namespace: namespace)
                .toolbar {
                    XDismissButton()
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
    }
}

fileprivate struct RefreshButton: View {
    @Binding var isRefreshing: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                withAnimation(.spring(response: 2.2)) { action() }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial.opacity(0.9))
                        .backgroundColor(opacity: 0.4)
                        .backgroundBlur(radius: 10)
                    
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .scaledToFill()
                        .imageScale(.large)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25)
                }
                .rotationEffect(Angle(degrees: isRefreshing ? 720 : 0))
                .frame(width: 45, height: 45)
            }
        }
        .padding(.trailing)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExploreView()
        }
    }
}
