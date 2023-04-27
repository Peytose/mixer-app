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
    @State var isShowingDetailView: Bool      = false
    @State var isShowingGuestlistView: Bool   = false
    @State var isShowingCreateEventView: Bool = false
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
                            if let event = viewModel.mapItems[host] as? CachedEvent {
                                self.selectedEvent = event
                            } else {
                                self.selectedHost = host
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
            if let event = selectedEvent {
                NavigationView {
                    EventDetailView(viewModel: EventDetailViewModel(event: event),
                                    namespace: namespace)
                    .toolbar {
                        ToolbarItem(placement: .destructiveAction) {
                            Button { isShowingDetailView = false  } label: { XDismissButton() }
                        }
                    }
                }
            } else if let host = selectedHost {
                NavigationView {
                    HostDetailView(viewModel: HostDetailViewModel(host: host), namespace: namespace)
                        .toolbar {
                            ToolbarItem(placement: .destructiveAction) {
                                Button { isShowingDetailView = false  } label: { XDismissButton() }
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $isShowingGuestlistView) {
            if let eventId = viewModel.hostEvents.first?.value.id, !viewModel.hostEvents.isEmpty {
                GuestlistView(viewModel: GuestlistViewModel(eventUid: eventId))
            }
        }
        .sheet(isPresented: $isShowingCreateEventView) {
            CreateEventFlow()
        }
        .overlay(alignment: .topTrailing) {
            if let isHost = AuthViewModel.shared.currentUser?.isHost {
                MapIconButton(icon: "plus", hasLargerSize: isHost) { isShowingCreateEventView.toggle() }
                    .padding(.trailing)
                    .padding(.top)
            }
        }
        .overlay(alignment: .bottom, content: {
            if let isHost = AuthViewModel.shared.currentUser?.isHost {
                MapWideButton(action: { isShowingGuestlistView.toggle() })
                    .padding(.bottom, 90)
            }
        })
        .overlay(alignment: .bottomTrailing) {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                viewModel.requestAlwaysOnLocationPermission()
            } label: {
                Image("recenter-button")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color.mainFont)
                    .frame(width: 25, height: 25)
                    .padding(10)
                    .background(Color.mixerSecondaryBackground)
                    .clipShape(Circle())
                    .shadow(radius: 5, y: 8)
            }
            .padding(.trailing)
            .padding(.bottom, 180)
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

fileprivate struct MapIconButton: View {
    let icon: String
    let hasLargerSize: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            action()
        } label: {
            Image(systemName: icon)
                .font(hasLargerSize ? .title2 : .title3)
                .fontWeight(.medium)
                .foregroundColor(Color.mainFont)
                .padding(hasLargerSize ? 15 : 10)
                .background(Color.mixerSecondaryBackground)
                .clipShape(Circle())
                .shadow(radius: 5, y: 8)
        }
    }
}

fileprivate struct MapWideButton: View {
    let action: () -> Void
    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        } label: {
            Capsule()
                .fill(Color.mixerSecondaryBackground)
                .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                .shadow(radius: 20, x: -8, y: -8)
                .shadow(radius: 20, x: 8, y: 8)
                .overlay {
                    HStack {
                        Image(systemName: "list.clipboard")
                            .imageScale(.large)
                            .foregroundColor(.mainFont)

                        Text("GuestList")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                    }
                }
                        .shadow(radius: 5, y: 10)
        }
    }
}
