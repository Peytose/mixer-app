//
//  MapView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct ButtonData {
    let title: String
    let symbol: String
    let action: () -> Void
}

struct MapView: View {
    
    @Environment(\.openURL) private var openURL
    @State private var selectedTag: Int?
    @State private var isSheetPresented = false
    @State private var travelTime: TimeInterval?
    
    @ObservedObject var viewModel: MapViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @Binding var mapState: MapViewState
    
    @Namespace var namespace
    @State private var buttons: [ButtonData] = []
    @State private var travelTimeByCar: TimeInterval?
    @State private var travelTimeByWalking: TimeInterval?
    @State private var travelTimeByTransit: TimeInterval?

    var body: some View {
        ZStack {
            Group {
                if #available(iOS 17, *) {
                    Map(position: getCameraPositionBinding(), selection: $selectedTag) {
                        ForEach(Array(viewModel.mapItems.enumerated()), id: \.element.id) { index, item in
                            Annotation(item.title,
                                       coordinate: item.coordinate) {
                                MixerAnnotation(viewModel: viewModel,
                                                index: index)
                            }
                                       .annotationTitles(.hidden)
                                       .tag(index)
                        }
                        
                        UserAnnotation()
                    }
                } else {
                    Map(coordinateRegion: $viewModel.region,
                        annotationItems: viewModel.mapItems) { item in
                        MapAnnotation(coordinate: item.coordinate) {
                            if let itemId = item.id,
                               let index = viewModel.mapItems.firstIndex(where: { $0.id == itemId }) {
                                MixerAnnotation(viewModel: viewModel,
                                                index: index)
                                .onTapGesture {
                                    self.selectedTag = index
                                }
                            }
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .overlay(alignment: .top) {
                LogoView(frameWidth: 65)
                    .shadow(radius: 10)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    viewModel.centerMapOnUserLocation()
                } label: {
                    Image(systemName: viewModel.isCenteredOnUserLocation ? "location.fill" : "location")
                        .font(.title3)
                        .foregroundColor(Color.theme.mixerIndigo)
                        .padding(10)
                        .background {
                            Circle()
                                .fill(Color.theme.secondaryBackgroundColor)
                                .shadow(color: .black, radius: 3)
                        }
                }
                .padding(.trailing)
                .padding(.bottom, 150)
                .opacity(isSheetPresented ? 0 : 1)
            }
            .onChange(of: selectedTag) { index in
                isSheetPresented = index != nil
                self.buttons = createButtons()

                // Reset travel times when selection changes
                self.travelTimeByCar = nil
                self.travelTimeByWalking = nil
                self.travelTimeByTransit = nil

                if let index = index, index < viewModel.mapItems.count {
                    let destination = viewModel.mapItems[index].coordinate
                    // Calculate for automobile
                    viewModel.calculateTravelTime(to: destination, transportType: .automobile) { time, error in
                        if let time = time {
                            print("Car travel time: \(time)")
                            self.travelTimeByCar = time
                        } else if let error = error {
                            print("Error calculating car travel time: \(error.localizedDescription)")
                        }
                    }
                    // Calculate for walking
                    viewModel.calculateTravelTime(to: destination, transportType: .walking) { time, error in
                        if let time = time {
                            print("Walking travel time: \(time)")
                            self.travelTimeByWalking = time
                        } else if let error = error {
                            print("Error calculating walking travel time: \(error.localizedDescription)")
                        }
                    }
                    // Calculate for transit
                    viewModel.calculateTravelTime(to: destination, transportType: .transit) { time, error in
                        if let time = time {
                            print("Transit travel time: \(time)")
                            self.travelTimeByTransit = time
                        } else if let error = error {
                            print("Error calculating transit travel time: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .sheet(isPresented: $isSheetPresented, onDismiss: { self.selectedTag = nil }) {
                if let index = self.selectedTag, index < viewModel.mapItems.count {
                    // Ensure the argument labels here match the ones in your MapItemDetailSheetView initializer
                    MapItemDetailSheetView(
                        selectedItem: viewModel.mapItems[index],
                        buttons: self.buttons,
                        getDirectionsAction: viewModel.getDirectionsToLocation,
                        viewModel: viewModel,
                        travelTimeByWalk: self.travelTimeByWalking,  // Make sure labels match
                        travelTimeByCar: self.travelTimeByCar,       // Make sure labels match
                        travelTimeByTransit: self.travelTimeByTransit // Make sure labels match
                    )
                    .presentationDetents([.medium, .large])
                }
            }
        }
    }
}

extension MapView {
    func createButtons() -> [ButtonData] {
        guard let selectedTag = selectedTag, viewModel.mapItems.indices.contains(selectedTag) else {
            return []
        }
        
        let hostDetailsButton = ButtonData(title: "Host Details", symbol: "person.fill") {
            guard let hostId = viewModel.mapItems[selectedTag].id,
                  let host = HostManager.shared.hosts.first(where: { $0.id == hostId }) else { return }
            homeViewModel.navigate(to: .close, withHost: host)
        }
        
        let instagramButton = ButtonData(title: "Instagram", symbol: "instagram") {
            guard let hostId = viewModel.mapItems[selectedTag].id,
                  let host = HostManager.shared.hosts.first(where: { $0.id == hostId }),
                  let instagramUrl = URL(string: "https://www.instagram.com/\(host.instagramHandle ?? "mixerpartyapp")/") else { return }
            openURL(instagramUrl)
        }
        
        return [hostDetailsButton, instagramButton] // Add more buttons to this array
    }
    
    
    @available(iOS 17.0, *)
    func getCameraPositionBinding() -> Binding<MapCameraPosition> {
        // Convert region to MapCameraPosition and return as Binding
        return .constant(MapCameraPosition.region(viewModel.region))
    }
}

struct MapView_Previews: PreviewProvider {
    static var viewModel = MapViewModel()
    
    static var previews: some View {
        MapView(viewModel: MapViewModel(),
                mapState: .constant(MapViewState.noInput))
        .environmentObject(viewModel)
    }
}
