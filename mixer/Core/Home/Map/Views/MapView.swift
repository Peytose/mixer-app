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
    
    @ObservedObject var viewModel: MapViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @Binding var mapState: MapViewState
    
    @Namespace var namespace
    @State private var buttons: [ButtonData] = []
    
    var body: some View {
        ZStack {
            Map(position: $viewModel.cameraPostition, selection: $selectedTag) {
                ForEach(viewModel.mapItems.indices, id: \.self) { index in
                    if let itemId = viewModel.mapItems[index].id {
                        Annotation(viewModel.mapItems[index].title,
                                   coordinate: viewModel.mapItems[index].coordinate) {
                            MixerAnnotation(item: viewModel.mapItems[index],
                                            number: viewModel.hostEventCounts[itemId] ?? 0)
                        }
                        .annotationTitles(.hidden)
                        .tag(index)
                    }
                }
                
                UserAnnotation()
            }
            .edgesIgnoringSafeArea(.bottom)
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
                            RoundedRectangle(cornerRadius: 10)
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
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack(alignment: .leading, spacing: 0) {
                    if let index = self.selectedTag, index < viewModel.mapItems.count {
                        let totalButtons = buttons.count + 1 // +1 for the "More" button
                        let horizontalPadding: CGFloat = 16 // Total horizontal padding (8 on each side)
                        let buttonSpacing: CGFloat = 8 // Spacing between buttons
                        let totalSpacing = buttonSpacing * CGFloat(totalButtons - 1)
                        let availableWidth = DeviceTypes.ScreenSize.width - horizontalPadding - totalSpacing
                        let buttonWidth = availableWidth / CGFloat(totalButtons)
                        
                        Text(viewModel.mapItems[index].title)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(.leading)
                            .padding(.bottom)
                        
                        HStack(spacing: buttonSpacing) {
                            ForEach(Array(buttons.indices), id: \.self) { index in
                                Button(action: buttons[index].action) {
                                    VStack(spacing: 5) {
                                        (buttons[index].symbol == "instagram" ? Image(buttons[index].symbol) : Image(systemName: buttons[index].symbol))
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(.white)
                                            .frame(width: 20, height: 20)
                                        
                                        Text(buttons[index].title)
                                            .foregroundStyle(.white)
                                            .font(.footnote)
                                    }
                                    .frame(width: buttonWidth, height: buttonWidth * 0.6)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(index == 0 ? Color.theme.mixerIndigo : Color.theme.secondaryBackgroundColor)
                                    }
                                }
                            }
                            
                            VStack(spacing: 5) {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                
                                Text("More")
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                            }
                            .frame(width: buttonWidth, height: buttonWidth * 0.6)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.theme.secondaryBackgroundColor)
                            }
                            .contextMenu {
                                Button {
                                    
                                } label: {
                                    Label(
                                        title: { Text("Report an Issue") },
                                        icon: { Image(systemName: "exclamationmark.bubble") }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if #available(iOS 17.0, *) {
                            LocationPreviewLookAroundView(selectedItem: viewModel.mapItems[index])
                                .frame(height: DeviceTypes.ScreenSize.height * 0.2)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding([.top, .horizontal])
                        } else {
                            MapSnapshotView(location: .constant(viewModel.mapItems[index].coordinate),
                                            snapshotWidth: DeviceTypes.ScreenSize.width - 16,
                                            snapshotHeight: DeviceTypes.ScreenSize.height * 0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                            .onTapGesture {
                                viewModel.getDirectionsToLocation(with: viewModel.mapItems[index].title,
                                                                  coordinates: viewModel.mapItems[index].coordinate)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.backgroundColor.ignoresSafeArea())
                .presentationDetents([.height(DeviceTypes.ScreenSize.height * 0.45)])
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
}

struct MapView_Previews: PreviewProvider {
    static var viewModel = MapViewModel()
    
    static var previews: some View {
        MapView(viewModel: MapViewModel(),
                mapState: .constant(MapViewState.noInput))
        .environmentObject(viewModel)
    }
}
