//
//  SelectAddressView.swift
//  mixer
//
//  Created by Jose Martinez on 11/16/23.
//

import SwiftUI
import MapKit

struct SelectAddressView: View {
    @Binding var text: String
    @Binding var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        List {
            textCell
            
            SelectedLocationMapView(coordinate: coordinate)
                .frame(width: DeviceTypes.ScreenSize.width - 50, height: 200) // Set the desired height for the map view
                .listRowBackground(Color.clear)
                .cornerRadius(16)
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .listStyle(.insetGrouped)
        .background(Color.theme.backgroundColor)
        .navigationBar(title: "Edit Address", displayMode: .inline)
    }
}

extension SelectAddressView {
    var textCell: some View {
        SettingsSectionContainer(header: "title") {
            MapPickerCell(coordinate: $coordinate, value: $text)
        }
    }
}

fileprivate struct MapPickerCell: View {
    @State var showPicker = false
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var value: String
    
    var body: some View {
        VStack {
            Button {
                showPicker.toggle()
            } label: {
                Text(value)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .leading
                    )
                //                    .lineLimit(1)
                //                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(.plain)
            
            // Your mapItemPicker implementation
            .mapItemPicker(isPresented: $showPicker) { item in
                if let placemark = item?.placemark {
                    self.value = placemark.title ?? ""
                    self.coordinate = placemark.coordinate
                }
            }
            
        }
    }
}

fileprivate struct SelectedLocationMapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
        
        // Remove existing annotations
        uiView.removeAnnotations(uiView.annotations)
        
        // Add new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)
    }
}
