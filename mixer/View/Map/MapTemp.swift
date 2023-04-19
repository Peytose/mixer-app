//
//  MapTemp.swift
//  mixer
//
//  Created by Peyton Lyons on 2/4/23.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct MapTemp: View {
    @ObservedObject var viewModel = MapViewModel()
    @State var isShowingDetailView: Bool    = false
    @State var isShowingGuestListView: Bool = false
    @State private var selectedEvent: CachedEvent?
    @State private var selectedHost: CachedHost?
    @State private var progress: CGFloat = 0
    let gradient1 = Gradient(colors: [.purple, .yellow])
    let gradient2 = Gradient(colors: [.blue, .purple])
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.mapItems.keys.compactMap { $0 }) { host in
                MapAnnotation(coordinate: host.location?.locationCoordinate ?? CLLocationCoordinate2D(latitude: 42.3598, longitude: 71.0921),
                              anchorPoint: CGPoint(x: 0.75, y: 0.75)) {
                    HostMapAnnotation(host: host)
                        .onTapGesture {
                            self.selectedHost = host
                            if let event = viewModel.mapItems[host] as? CachedEvent {
                                self.selectedEvent = event
                            }
                            
                            isShowingDetailView = true
                        }
                }
            }
            .ignoresSafeArea()
            
            Spacer()
            
            LogoView(frameWidth: 75)
                .animatableGradient(fromGradient: gradient1,
                                    toGradient: gradient2,
                                    progress: progress)
                .frame(height: 75)
                .mask(LogoView(frameWidth: 75))
                .shadow(radius: 10)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                        self.progress = 1.0
                    }
                }
        }
        .sheet(isPresented: $isShowingDetailView) {
            ZStack {
                if let event = selectedEvent {
                    NavigationView {
                        EventDetailView(viewModel: EventDetailViewModel(event: event),
                                        namespace: namespace)
                            .toolbar {
                                Button("Dismiss", action: { isShowingDetailView = false })
                            }
                            .onAppear { viewModel.isLoading = false }
                    }
                } else if let host = selectedHost {
                    NavigationView {
                        HostDetailView(viewModel: HostDetailViewModel(host: host), namespace: namespace)
                            .toolbar {
                                Button("Dismiss", action: { isShowingDetailView = false })
                            }
                            .onAppear { viewModel.isLoading = false }
                    }
                }
                
                if viewModel.isLoading { LoadingView() }
            }
            .onAppear { viewModel.isLoading = true }
        }
        .sheet(isPresented: $isShowingGuestListView) {
            if let eventId = viewModel.hostEvents.first?.value.id {
                GuestlistView(viewModel: GuestlistViewModel(eventUid: eventId))
            }
        }
        .overlay(alignment: .bottomLeading, content: {
            LocationButton(.currentLocation) {
                viewModel.requestAlwaysOnLocationPermission()
            }
            .foregroundColor(.white)
            .symbolVariant(.fill)
            .tint(.mixerIndigo)
            .labelStyle(.iconOnly)
            .clipShape(Circle())
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 100, trailing: 0))
        })
        .overlay(alignment: .topTrailing) {
            if !viewModel.hostEvents.isEmpty {
                    EventUsersListButton(action: $isShowingGuestListView)
            }
        }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .task {
            viewModel.getMapItems()
            viewModel.getEventForGuestlist()
        }
    }
}

struct MapTemp_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        MapTemp(namespace: namespace)
    }
}

fileprivate struct EventUsersListButton: View {
    @Binding var action: Bool
    var body: some View {
        Image(systemName: "list.clipboard")
            .font(.title2.weight(.medium))
            .foregroundColor(Color.mainFont)
            .padding(10)
            .background(Color.mixerSecondaryBackground)
            .clipShape(Circle())
            .shadow(radius: 5, y: 8)
            .onTapGesture {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                action.toggle()
            }
    }
}
