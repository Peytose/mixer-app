//
//  EventLocationAndDates.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI
import MapKit
import MapItemPicker

struct EventLocationAndDates: View {
    @StateObject private var handler = AddressSearchHandler()
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var address: String
    @Binding var publicAddress: String
    @Binding var hasPublicAddress: Bool
    @Binding var coordinate: CLLocationCoordinate2D?
    
    @State private var showSearch = true
    @FocusState private var addressSearchIsFocused: Bool
    @State private var useDefaultAddress = false
    @State private var selectedLocation: IdentifiableLocation?
    @State private var PickerAddress: String = "528 Beacon St"
    @State var showingPicker = false
    let action: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("When")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 13) {
                        // Start Date Selection : now - 3 months
                        CustomDateSelection(text: "Start date",
                                            date: $startDate,
                                            range: Date.now...Date.now.addingTimeInterval(7889400))
                        
                        VStack(alignment: .leading) {
                            // End Date Selection : 1 hour - 25 hours
                            CustomDateSelection(text: "End date",
                                                date: $endDate,
                                                range: startDate.addingTimeInterval(3600)...startDate.addingTimeInterval(86460))
                            
                            // More info about end date.
                            HStack(alignment: .center) {
                                Image(systemName: "info.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.secondary)
                                    .frame(width: 20, height: 20)
                                
                                Text("What if I don't have an end time?")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    AddressPickerView(selectedCoordinate: $coordinate, hasPublicAddress: $hasPublicAddress, publicAddress: $publicAddress, address: $address)
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color.mixerBackground)
        .onTapGesture {
            self.hideKeyboard()
        }
        .overlay(alignment: .bottom) {
            if address.isEmpty {
                CreateEventNextButton(text: "Continue", action: action, isActive: false)
                    .disabled(true)
            } else {
                CreateEventNextButton(text: "Continue", action: action, isActive: true)
            }
    }
    }
}

//struct EventLocationAndDates_Previews: PreviewProvider {
//    static var previews: some View {
//        EventLocationAndDates(startDate: .constant(Date.now), endDate: .constant(Date().addingTimeInterval(3700)), address: .constant(""), publicAddress: .constant(""), usePublicAddress: .constant(false)) {}
//            .preferredColorScheme(.dark)
//    }
//}

fileprivate struct CustomDateSelection: View {
    let text: String
    @Binding var date: Date
    let range: ClosedRange<Date>
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(text)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.95)
            
            Spacer()
            
            DatePicker("", selection: $date,
                       in: range,
                       displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
            .labelsHidden()
        }
        .padding()
        .background(alignment: .center) {
            RoundedRectangle(cornerRadius: 9)
                .stroke(lineWidth: 3)
                .foregroundColor(.mixerIndigo)
        }
    }
}

struct AddressPickerView: View {
    @State private var selectedMapItem: MKMapItem?
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showingPicker = false
    @Binding var hasPublicAddress: Bool
    @Binding var publicAddress: String
    @Binding var address: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(selectedMapItem?.placemark.title ?? "Tap to choose address")
                .foregroundColor(Color.mainFont)
                .font(.title3)
                .tint(Color.mixerIndigo)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 3)
                        .foregroundColor(Color.mixerIndigo)
                }
                .onTapGesture {
                    showingPicker = true
                }
            
            Text("Shown only to approved guests")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Toggle("Set public address", isOn: $hasPublicAddress.animation())
                .font(.body)
                .fontWeight(.semibold)
                .tint(Color.mixerIndigo)
                .padding(.bottom, 4)
            
            if hasPublicAddress {
                CreateEventTextField(input: $publicAddress, title: "Public Address", placeholder: "e.g., Back Bay, Boston", footnote: "Loosely describe the area. Shown to all users", keyboard: .default, toggleBool: .constant(false))
                    .zIndex(2)
            }
            
            Map(coordinateRegion: $mapRegion,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: .constant(.none),
                annotationItems: [AnnotationItem(coordinate: selectedCoordinate ?? CLLocationCoordinate2D(latitude: 42.350710, longitude: -71.090980))]) { item in
                MapMarker(coordinate: item.coordinate)
            }
                .frame(height: 300)
                .cornerRadius(9)
        }
        .mapItemPicker(isPresented: $showingPicker) { item in
            if let coordinate = item?.placemark.coordinate {
                selectedMapItem = item
                selectedCoordinate = coordinate
                address = item?.placemark.title ?? "Unknown"
                mapRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
            }
        }
    }

    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.3551, longitude: -71.0839), span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
}

struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
