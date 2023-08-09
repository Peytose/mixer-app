////
////  EventLocationAndDates.swift
////  mixer
////
////  Created by Peyton Lyons on 3/15/23.
////
//
//import SwiftUI
//import MapKit
//import MapItemPicker
//
//struct EventLocationAndDates: View {
//    @EnvironmentObject var viewModel: EventFlowViewModel
//    
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(alignment: .leading, spacing: 35) {
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("When")
//                        .primaryHeading()
//                    
//                    VStack(spacing: 13) {
//                        // Start Date Selection : now - 3 months
//                        CustomDateSelection(text: "Start date",
//                                            date: $viewModel.startDate,
//                                            range: Date.now...Date.now.addingTimeInterval(7889400))
//                        
//                        // End Date Selection : 1 hour - 25 hours
//                        CustomDateSelection(text: "End date",
//                                            date: $viewModel.endDate,
//                                            range: viewModel.startDate.addingTimeInterval(3600)...viewModel.startDate.addingTimeInterval(86460))
//                    }
//                }
//                
//                AddressPickerView(selectedCoordinate: $viewModel.coordinates,
//                                  altAddress: $viewModel.altAddress,
//                                  address: $viewModel.address)
//            }
//            .padding()
//            .padding(.bottom, 80)
//        }
//        .background(Color.theme.backgroundColor)
//        .onTapGesture {
//            self.hideKeyboard()
//        }
//    }
//}
//
//fileprivate struct CustomDateSelection: View {
//    let text: String
//    @Binding var date: Date
//    let range: ClosedRange<Date>
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 0) {
//            Text(text)
//                .font(.title3)
//                .fontWeight(.medium)
//                .lineLimit(1)
//                .minimumScaleFactor(0.95)
//            
//            Spacer()
//            
//            DatePicker("", selection: $date,
//                       in: range,
//                       displayedComponents: [.date, .hourAndMinute])
//            .datePickerStyle(.compact)
//            .labelsHidden()
//        }
//        .padding()
//        .background(alignment: .center) {
//            RoundedRectangle(cornerRadius: 9)
//                .stroke(lineWidth: 1)
//                .foregroundColor(Color.theme.mixerIndigo)
//        }
//    }
//}
//
//struct AddressPickerView: View {
//    @Binding var selectedCoordinate: CLLocationCoordinate2D?
//    @Binding var altAddress: String
//    @Binding var address: String
//    
//    @State private var selectedMapItem: MKMapItem?
//    @State private var hasPublicAddress = false
//    @State private var showingPicker = false
//    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.3551, longitude: -71.0839), span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Where")
//                .primaryHeading()
//            
//            Text(selectedMapItem?.placemark.title ?? "Tap to choose address")
//                .foregroundColor(.white)
//                .font(.title3)
//                .tint(Color.theme.mixerIndigo)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
//                .background {
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(lineWidth: 1)
//                        .foregroundColor(Color.theme.mixerIndigo)
//                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    showingPicker = true
//                }
//            
//            Text("Shown only to approved guests")
//                .footnote()
//            
//            Toggle("Set public address", isOn: $hasPublicAddress.animation())
//                .font(.body)
//                .fontWeight(.semibold)
//                .tint(Color.theme.mixerIndigo)
//                .padding(.bottom, 4)
//            
//            if hasPublicAddress {
//                EventFlowTextField(title: "Public Address",
//                                   placeholder: "e.g., Back Bay, Boston",
//                                   footnote: "Loosely describe the area. Shown to all users",
//                                   input: $address,
//                                   isNoteAdded: .constant(false),
//                                   keyboardType: .default)
//                    .zIndex(2)
//            }
//            
//            Map(coordinateRegion: $mapRegion,
//                interactionModes: .all,
//                showsUserLocation: true,
//                userTrackingMode: .constant(.none),
//                annotationItems: [AnnotationItem(coordinate: selectedCoordinate ?? CLLocationCoordinate2D(latitude: 42.350710, longitude: -71.090980))]) { item in
//                MapMarker(coordinate: item.coordinate)
//            }
//                .frame(height: 300)
//                .cornerRadius(8)
//        }
//        .mapItemPicker(isPresented: $showingPicker) { item in
//            if let coordinate = item?.placemark.coordinate {
//                selectedMapItem = item
//                selectedCoordinate = coordinate
//                address = item?.placemark.title ?? "Unknown"
//                mapRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
//            }
//        }
//    }
//}
//
//struct AnnotationItem: Identifiable {
//    let id = UUID()
//    let coordinate: CLLocationCoordinate2D
//}
