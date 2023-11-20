//
//  MapView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import SwiftUI

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
                            MixerMapViewRepresentable(mapState: $mapState)
                                .ignoresSafeArea()
                            
                            LogoView(frameWidth: 65)
                                .shadow(radius: 10)
                                .allowsHitTesting(false)
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .sheet(isPresented: $viewModel.showLocationDetailsCard) {
                        EmptyView()
                            .presentationDetents([.medium])
                    }
                    
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
