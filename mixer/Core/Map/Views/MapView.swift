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
    
    var body: some View {
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
//            LocationDetailsCardView()
            EmptyView()
                .presentationDetents([.medium])
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(mapState: .constant(MapViewState.noInput))
    }
}
