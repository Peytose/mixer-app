//
//  EventLocationAndDates.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI
import MapKit

struct EventLocationAndDates: View {
    @StateObject private var handler = AddressSearchHandler()
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var address: String
    @State private var showSearch = true
    @FocusState private var addressSearchIsFocused: Bool
    @State private var useDefaultAddress = false
    @State private var selectedLocation: IdentifiableLocation?
    let action: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("When")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 13) {
                        // Start Date Selection : now - 3 months
                        CustomDateSelection(text: "Start date",
                                            date: $startDate,
                                            range: Date.now...Date.now.addingTimeInterval(7889400))
                        .padding()
                        .background(alignment: .center) {
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.mixerPurple)
                        }
                        
                        VStack(alignment: .leading) {
                            // End Date Selection : 1 hour - 25 hours
                            CustomDateSelection(text: "End date",
                                                date: $endDate,
                                                range: startDate.addingTimeInterval(3600)...startDate.addingTimeInterval(86460))
                            .padding()
                            .background(alignment: .center) {
                                RoundedRectangle(cornerRadius: 9)
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(.mixerPurple)
                            }
                            
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
                    Text("Where")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .center) {
                        if showSearch {
                            TextField("Search for an address", text: $handler.searchQuery)
                                .padding()
                                .background(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 9)
                                        .stroke(lineWidth: 2)
                                        .foregroundColor(.mixerPurple)
                                }
                                .focused($addressSearchIsFocused)
                            
                            ForEach(handler.searchResults, id: \.placemark) { mapItem in
                                Button {
                                    if let location = mapItem.placemark.title {
                                        self.address = location
                                        self.selectedLocation = IdentifiableLocation(mapItem.placemark.coordinate)
                                        self.showSearch = false
                                        self.addressSearchIsFocused = false
                                    }
                                } label: {
                                    Text(mapItem.placemark.title ?? "No results for \(handler.searchQuery) ...")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        } else {
                            Button {
                                self.useDefaultAddress = false
                                self.showSearch = true
                                self.addressSearchIsFocused = true
                            } label: {
                                HStack(alignment: .center) {
                                    Text(address)
                                        .font(.callout)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.75)
                                        .multilineTextAlignment(.leading)
                                
                                    Spacer()
                                }
                                .padding()
                                .background(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 9)
                                        .stroke(lineWidth: 2)
                                        .foregroundColor(.mixerPurple)
                                }
                            }
                        }
                        
                        if let defaultAddress = AuthViewModel.shared.currentUser?.associatedHostAccount?.address {
                            Toggle(isOn: $useDefaultAddress) {
                                Text("Use default address")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .tint(Color.mixerPurple)
                            .onChange(of: useDefaultAddress) { _ in
                                self.address = useDefaultAddress ? defaultAddress : ""
                                self.showSearch = !useDefaultAddress
                                self.addressSearchIsFocused = !useDefaultAddress
                            }
                        }
                    }
                    
                    CustomMapView(selectedLocation: $selectedLocation)
                        .frame(height: 300)
                        .cornerRadius(9)
                }
                
                VStack(alignment: .center) { NextButton(action: action) }
            }
            .padding()
        }
        .background(Color.mixerBackground)
    }
}

struct EventLocationAndDates_Previews: PreviewProvider {
    static var previews: some View {
        EventLocationAndDates(startDate: .constant(Date.now), endDate: .constant(Date().addingTimeInterval(3700)), address: .constant("")) {}
            .preferredColorScheme(.dark)
    }
}

fileprivate struct CustomDateSelection: View {
    let text: String
    @Binding var date: Date
    let range: ClosedRange<Date>
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(text)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            Spacer()
            
            DatePicker("", selection: $date,
                       in: range,
                       displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
        }
    }
}
