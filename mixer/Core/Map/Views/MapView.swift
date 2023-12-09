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
    @State private var selectedTag: Int?
    @State private var isSheetPresented = false
    @EnvironmentObject var viewModel: MapViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var mapState: MapViewState
    @Binding var context: [NavigationContext]
    @Namespace var namespace
    @State private var buttons: [ButtonData] = []
    
    var body: some View {
        ZStack {
            if let state = context.last?.state {
                switch state {
                case .menu:
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
                                            .foregroundStyle(.white)
                                            .font(.footnote)
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

                                LocationPreviewLookAroundView(selectedItem: viewModel.mapItems[index])
                                    .frame(height: DeviceTypes.ScreenSize.height * 0.2)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding([.top, .horizontal])
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.theme.backgroundColor.ignoresSafeArea())
                        .presentationDetents([.height(DeviceTypes.ScreenSize.height * 0.2),
                                              .height(DeviceTypes.ScreenSize.height * 0.4)])
                    }


                    
                case .back, .close:
                    hostDetailView()
                    
                    eventDetailView()
                }
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
            // Instagram navigation logic
        }

        return [hostDetailsButton, instagramButton] // Add more buttons to this array
    }
}

struct MapView_Previews: PreviewProvider {
    static var viewModel = MapViewModel()
    
    static var previews: some View {
        MapView(mapState: .constant(MapViewState.noInput),
                context: .constant([NavigationContext(state: .menu)]))
        .environmentObject(viewModel)
    }
}
