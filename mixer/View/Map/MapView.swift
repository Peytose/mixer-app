//
//  MapView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/4/23.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: View {
    @ObservedObject var viewModel = MapViewModel()
    @State var isShowingEventDetailView: Bool = false
    @State var isShowingHostDetailView: Bool  = false
    @State var isShowingGuestlistView: Bool   = false
    @State var isShowingCreateEventView: Bool = false
    @State private var selectedEvent: CachedEvent?
    @State private var selectedHost: CachedHost?
    @State private var progress: CGFloat = 0
    let gradient1 = Gradient(colors: [.purple, .pink])
    let gradient2 = Gradient(colors: [.blue, .purple])
    var namespace: Namespace.ID
    
    var eventSheetBinding: Binding<Bool> {
        Binding {
            return isShowingEventDetailView && selectedEvent != nil && (viewModel.eventDetailViewModel?.isDataReady ?? false)
        } set: { newValue in
            isShowingEventDetailView = newValue
        }
    }

    var hostSheetBinding: Binding<Bool> {
        Binding {
            return isShowingHostDetailView && selectedHost != nil && (viewModel.hostDetailViewModel?.isDataReady ?? false)
        } set: { newValue in
            isShowingHostDetailView = newValue
        }
    }

    
    var body: some View {
        ZStack(alignment: .center) {
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
                                    viewModel.eventDetailViewModel = EventDetailViewModel(event: event)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isShowingEventDetailView = true
                                    }
                                } else {
                                    // Set the selected host
                                    self.selectedHost = host
                                    viewModel.hostDetailViewModel = HostDetailViewModel(host: host)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isShowingHostDetailView = true
                                    }
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                
                Spacer()
                
                LogoView(frameWidth: 65)
                    .shadow(radius: 10)
                    .allowsHitTesting(false)
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: eventSheetBinding) {
            if let event = selectedEvent {
                EventDetailView(viewModel: viewModel.eventDetailViewModel!,
                                namespace: namespace)
                .overlay(alignment: .topTrailing) {
                    Button { isShowingEventDetailView = false  } label: { XDismissButton() }
                }
            }
        }
        .sheet(isPresented: hostSheetBinding) {
            if let host = selectedHost {
                HostDetailView(viewModel: viewModel.hostDetailViewModel!,
                               namespace: namespace)
                .overlay(alignment: .topTrailing) {
                    Button { isShowingHostDetailView = false  } label: { XDismissButton() }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingGuestlistView) {
            if let event = viewModel.hostEvents.first?.value, !viewModel.hostEvents.isEmpty {
                GuestlistView(viewModel: GuestlistViewModel(event: event), isShowingGuestlistView: $isShowingGuestlistView)
                    .zIndex(2)
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateEventView) {
            CreateEventFlow(isShowingCreateEventView: $isShowingCreateEventView, namespace: namespace)
        }
        .overlay(alignment: .topTrailing) {
            if let isHost = AuthViewModel.shared.currentUser?.isHost {
                MapIconButton(icon: "plus", hasLargerSize: isHost) { isShowingCreateEventView.toggle() }
                    .padding(.trailing)
                    .padding(.top)
            }
        }
        .overlay(alignment: .bottom) {
            if let _ = AuthViewModel.shared.currentUser?.isHost {
                GuestlistButton { isShowingGuestlistView.toggle() }
                    .padding(.bottom, 100)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
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

struct MapView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        MapView(namespace: namespace)
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
                .background(Color.mixerPurpleGradient)
                .clipShape(Circle())
                .shadow(radius: 5, y: 8)
        }
    }
}

fileprivate struct GuestlistButton: View {
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
                        
                        Text("Guestlist")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                    }
                }
                .shadow(radius: 5, y: 10)
        }
    }
}
