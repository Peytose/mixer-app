//
//  MapViewActionButton.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI

struct MapViewActionButton: View {
    @Binding var mapState: MapViewState
    @Binding var showSideMenu: Bool
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                actionForState(mapState)
            }
        } label: {
            Image(systemName: imageNameForState(mapState))
                .font(.title2)
                .foregroundColor(.black)
                .padding()
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black, radius: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
    func actionForState(_ state: MapViewState) {
        switch state {
            case .noInput:
                showSideMenu.toggle()
            case .guestlist:
                mapState = .noInput
            case .discovering:
                mapState = .noInput
                homeViewModel.clearInput()
            case .polylineAdded:
                mapState = .noInput
                homeViewModel.selectedMixerLocation = nil
                homeViewModel.clearInput()
            case .eventDetail, .hostDetail:
                mapState = .discovering
                homeViewModel.selectedEvent = nil
                homeViewModel.selectedHost = nil
            default: break
        }
    }
    
    
    func imageNameForState(_ state: MapViewState) -> String {
        switch state {
            case .noInput:
                return showSideMenu ? "chevron.right" : "line.3.horizontal"
            case .guestlist,
                .discovering,
                .polylineAdded,
                .routeEventPreview,
                .routeHostPreview,
                .eventDetail,
                .hostDetail:
                return "arrow.left"
        }
    }
}

struct MapViewActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MapViewActionButton(mapState: .constant(.noInput),
                            showSideMenu: .constant(false))
    }
}
