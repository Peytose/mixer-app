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
    @State var isShowingDetailView = false
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
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: host.latitude!,
                                                                 longitude: host.longitude!),
                              anchorPoint: CGPoint(x: 0.75, y: 0.75)) {
                    HostMapAnnotation(host: host)
                        .onTapGesture {
                            self.selectedHost = host
                            print("DEBUG: selectedHost \(host)")
                            print("DEBUG: event associated \(String(describing: viewModel.mapItems[host]))")
                            
                            if let event = viewModel.mapItems[host] as? CachedEvent {
                                self.selectedEvent = event
                                print("DEBUG: selectedEvent :     \(String(describing: self.selectedEvent))")
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
        .overlay(alignment: .bottomLeading, content: {
            LocationButton(.currentLocation) {
                viewModel.requestAllowOnceLocationPermission()
            }
            .foregroundColor(.white)
            .symbolVariant(.fill)
            .tint(.mixerIndigo)
            .labelStyle(.iconOnly)
            .clipShape(Circle())
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 100, trailing: 0))
        })
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .task { viewModel.getMapItems() }
    }
}

struct MapTemp_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        MapTemp(namespace: namespace)
    }
}
