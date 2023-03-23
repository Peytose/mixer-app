//
//  CustomMapView.swift
//  mixer
//
//  Created by Peyton Lyons on 3/21/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct IdentifiableLocation: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D

    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    static func ==(lhs: IdentifiableLocation, rhs: IdentifiableLocation) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CustomMapView: View {
    @Binding var selectedLocation: IdentifiableLocation?
    @State private var region: MKCoordinateRegion
    
    init(selectedLocation: Binding<IdentifiableLocation?>) {
        self._selectedLocation = selectedLocation
        
        // Set the initial region to the default location.
        let initialCenter = CLLocationCoordinate2D(latitude: 42.3598, longitude: -71.0921)
        let initialSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        self._region = State(initialValue: MKCoordinateRegion(center: initialCenter, span: initialSpan))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: selectedLocation.map { [$0] } ?? [], annotationContent: { item in
            MapMarker(coordinate: item.coordinate, tint: .red)
        })
        .onChange(of: selectedLocation) { newLocation in
            // Update the region to use the coordinates of the selected location, or the default coordinates if there isn't one.
            let coordinates = newLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 42.3598, longitude: -71.0921)
            region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
    }
}

struct MarkerView: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
            Image(systemName: "mappin")
                .foregroundColor(.red)
        }
    }
}
