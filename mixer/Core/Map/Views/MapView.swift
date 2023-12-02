//
//  MapView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var viewModel: MapViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var mapState: MapViewState
    @Binding var context: [NavigationContext]
    @Namespace var namespace
    
    var body: some View {
        if let state = context.last?.state {
            switch state {
                case .menu:
                    ZStack(alignment: .bottom) {
                        ZStack(alignment: .top) {
                            Map {
                                ForEach(Array(viewModel.mapItems)) { item in
                                    if let itemId = item.id {
                                        Annotation(item.title, coordinate: item.coordinate) {
                                            MixerAnnotation(item: item,
                                                            number: viewModel.hostEventCounts[itemId] ?? 0)
                                        }
                                        .annotationTitles(.hidden)
                                    }
                                }
                                
                                UserAnnotation()
                            }
                            .tint(Color.theme.mixerIndigo)
                            .mapStyle(.standard)
                            .mapControls {
                                MapCompass()
                                MapUserLocationButton()
                                MapPitchToggle()
                                MapScaleView()
                            }
                            
                            LogoView(frameWidth: 65)
                                .shadow(radius: 10)
                                .allowsHitTesting(false)
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    
                case .back, .close:
                    hostDetailView()
                    
                    eventDetailView()
            }
        }
    }
}

extension MapView {
    @ViewBuilder
    func eventDetailView() -> some View {
        if let event = context.last?.selectedEvent {
            EventDetailView(event: event,
                            action: homeViewModel.navigate,
                            namespace: namespace)
        }
    }

    @ViewBuilder
    func hostDetailView() -> some View {
        if let host = context.last?.selectedHost {
            HostDetailView(host: host,
                           action: homeViewModel.navigate,
                           namespace: namespace)
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView(mapState: .constant(MapViewState.noInput))
//    }
//}
