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
    
    @State private var selectedMode: MKDirectionsTransportType = .automobile
    @State private var travelIcon = "car.fill"
    @State private var showMailModal = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                detailHeaderView
                buttonsView
                mapView
                travelDetailsView
                getDirectionsButton
            }
            .padding(.horizontal)
            .padding(.top, 30)
        }
        .background(Color.theme.backgroundColor.ignoresSafeArea())
        .onAppear(perform: setupAddresses)
        .sheet(isPresented: $showMailModal) {
            MailViewModal(isShowing: $showMailModal, subject: "mixer", recipients: ["josemartinez102001@gmail.com"])
        }
    }
}

extension MapItemDetailSheetView {
    var detailHeaderView: some View {
        Text(selectedItem.title)
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(Color.white)
            .padding(.bottom)
    }
    
    var buttonsView: some View {
        HStack(spacing: 8) {
            
            ForEach(Array(buttons.indices), id: \.self) { index in
                Button(action: buttons[index].action) {
                    buttonContent(for: buttons[index])
                    Spacer()
                }
            }
            
            moreButton
        }
    }
    
    var mapView: some View {
        Group {
            if #available(iOS 17.0, *) {
                LocationPreviewLookAroundView(selectedItem: selectedItem)
                    .frame(height: 200)
            } else {
                MapSnapshotView(location: .constant(selectedItem.coordinate),
                                snapshotWidth: UIScreen.main.bounds.width - 32,
                                snapshotHeight: 200)
                .onTapGesture {
                    getDirectionsAction?(selectedItem.title, selectedItem.coordinate, selectedMode.directionsMode)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.top)
    }
    
    var travelDetailsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Travel Details")
                    .font(.title2)
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
            
            TravelTimeView(userAddress: userAddress, destinationTitle: selectedItem.title, destinationAddress: destinationAddress)
        }
        .padding(.vertical)
    }
    
    var getDirectionsButton: some View {
        HStack {
            Spacer()
            
            Button {
                getDirectionsAction?(selectedItem.title, selectedItem.coordinate, selectedMode.directionsMode)
            } label: {
                HStack {
                    Text("\(Image(systemName: travelIcon)) - \(travelTimeText(for: selectedMode))")
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().fill(Color.theme.mixerIndigo))
                }
            }
            .padding(.bottom, 20)
            
            Spacer()
        }
    }
    
    var moreButton: some View {
        Menu {
//            Button("Share Host Profile", action: {})
            Button("Contact Host", action: { showMailModal.toggle() })
        } label: {
            VStack(spacing: 5) {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                
                Text("More")
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            .frame(height: 90)
            .frame(maxWidth: 110)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.theme.secondaryBackgroundColor))
        }
    }
    
    
    private func buttonContent(for buttonData: ButtonData) -> some View {
        VStack(spacing: 5) {
            (buttonData.symbol == "instagram" ? Image(.instagram) : Image(systemName: buttonData.symbol))
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
            
            Text(buttonData.title)
                .foregroundColor(.white)
                .font(.footnote)
        }
        .frame(height: 90)
        .frame(maxWidth: 110)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.theme.secondaryBackgroundColor))
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
}

extension MapItemDetailSheetView {
    private func setupAddresses() {
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
