//
//  MapItemDetailView.swift
//  mixer
//
//  Created by Jose Martinez on 2/6/24.
//

import SwiftUI
import MapKit

struct MapItemDetailSheetView: View {
    let selectedItem: MixerMapItem
    let buttons: [ButtonData]
    var getDirectionsAction: ((String, CLLocationCoordinate2D, String) -> Void)?
    @ObservedObject var viewModel: MapViewModel
    
    let travelTimeByWalk: TimeInterval?
    let travelTimeByCar: TimeInterval?
    let travelTimeByTransit: TimeInterval?
    
    @State private var userAddress: String = "Determining your location..."
    @State private var destinationAddress: String = "Determining destination address..."
    
    @State private var selectedMode: MKDirectionsTransportType = .automobile // Default selection
    @State private var travelIcon = "car.fill"



    var body: some View {
        let totalButtons = buttons.count + 1 // +1 for the "More" button
        let horizontalPadding: CGFloat = 16 // Total horizontal padding (8 on each side)
        let buttonSpacing: CGFloat = 8 // Spacing between buttons
        let totalSpacing = buttonSpacing * CGFloat(totalButtons - 1)
        let availableWidth = DeviceTypes.ScreenSize.width - horizontalPadding - totalSpacing
        let buttonWidth = availableWidth / CGFloat(totalButtons)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(selectedItem.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .padding(.bottom)
                
                HStack(spacing: 8) { // Assuming 8 is your buttonSpacing
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
                
                // Conditional view for iOS version
                if #available(iOS 17.0, *) {
                    LocationPreviewLookAroundView(selectedItem: selectedItem)
                        .frame(height: 200) // Example height
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.top])
                } else {
                    MapSnapshotView(location: .constant(selectedItem.coordinate),
                                    snapshotWidth: DeviceTypes.ScreenSize.width - 16,
                                    snapshotHeight: DeviceTypes.ScreenSize.height * 0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding([.top])
                    .onTapGesture {
                        getDirectionsAction?(selectedItem.title, selectedItem.coordinate, selectedMode.directionsMode)
                    }
                }
                
                HStack {
                      Text("Travel Details")
                          .font(.title)
                          .fontWeight(.semibold)
                          .foregroundColor(Color.white)
                      
                      Spacer()
                      
                      Menu {
                          Button("Car") { selectedMode = .automobile; travelIcon = "car.fill" }
                          Button("Walking") { selectedMode = .walking; travelIcon = "figure.walk" }
                          Button("Transit") { selectedMode = .transit; travelIcon = "bus.fill" }
                      } label: {
                          Text("Change Mode")
                              .foregroundColor(Color.theme.mixerIndigo)
                              .font(.headline)
                      }
                  }
                  .padding(.bottom)
                  .padding(.top)
    
                TravelTimeView(userAddress: userAddress, destinationTitle: selectedItem.title, destinationAddress: destinationAddress)

                Button(action: {
                    getDirectionsAction?(selectedItem.title, selectedItem.coordinate, selectedMode.directionsMode)
                }) {
                    HStack {
                        Text("\(Image(systemName: travelIcon)) - \(travelTimeText(for: selectedMode))")
                            .foregroundColor(.white)
                            .padding()
                            .background(Capsule().fill(Color.theme.mixerIndigo))
                    }
                    

                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 100) // Set the height accordingly
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.theme.backgroundColor.ignoresSafeArea())
        .onAppear {
            // Reverse geocode user location
            if let userLocation = viewModel.userLocation {
                reverseGeocodeCoordinate(userLocation) { address in
                    self.userAddress = address ?? "Location not found"
                }
            }

            // Reverse geocode selectedItem location
            reverseGeocodeCoordinate(selectedItem.coordinate) { address in
                self.destinationAddress = address ?? "Location not found"
            }
        }

    }

    private func travelTimeText(for mode: MKDirectionsTransportType) -> String {
        let time: TimeInterval? // Declare an optional TimeInterval to hold the value based on the mode
        switch mode {
        case .automobile: time = travelTimeByCar
        case .walking: time = travelTimeByWalk
        case .transit: time = travelTimeByTransit
        default: return "N/A"
        }
        
        // Now, safely unwrap 'time' or return "--" if nil
        if let unwrappedTime = time {
            return formatTravelTime(unwrappedTime) // This is safe since 'unwrappedTime' is non-optional
        } else {
            return "N/A" // Handle the case where 'time' is nil
        }
    }

    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil)
                return
            }

            let formattedAddress = [
                [placemark.subThoroughfare, placemark.thoroughfare].compactMap { $0 }.joined(separator: " "),
                [placemark.locality, placemark.administrativeArea].compactMap { $0 }.joined(separator: ", ")
            ].joined(separator: " ")


            completion(formattedAddress)
        }
    }
    
    private func formatTravelTime(_ time: TimeInterval) -> String {
        // Format the time interval into a readable format, e.g., "15 min"
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: time) ?? "N/A"
    }
}




extension MKDirectionsTransportType {
    var directionsMode: String {
        switch self {
        case .walking: return MKLaunchOptionsDirectionsModeWalking
        case .automobile: return MKLaunchOptionsDirectionsModeDriving
        case .transit: return MKLaunchOptionsDirectionsModeTransit
        default: return MKLaunchOptionsDirectionsModeDriving
        }
    }
}
