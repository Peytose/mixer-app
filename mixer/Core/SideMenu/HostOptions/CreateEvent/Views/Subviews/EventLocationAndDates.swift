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
    @EnvironmentObject var viewModel: EventCreationViewModel
    
    var body: some View {
        FlowContainerView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 35) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("When")
                            .primaryHeading()
                        
                        VStack(spacing: 13) {
                            // Start Date Selection : now - 3 months
                            CustomDateSelection(text: "Start date",
                                                date: $viewModel.startDate,
                                                range: Date.now...Date.now.addingTimeInterval(7889400))
                            
                            // End Date Selection : 1 hour - 25 hours
                            CustomDateSelection(text: "End date",
                                                date: $viewModel.endDate,
                                                range: viewModel.startDate.addingTimeInterval(3600)...viewModel.startDate.addingTimeInterval(86460))
                        }
                    }
                    
                    AddressPickerView(viewModel: viewModel)
                }
                .padding()
                .padding(.bottom, 80)
            }
        }
    }
}

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
                .stroke(lineWidth: 1)
                .foregroundColor(Color.theme.mixerIndigo)
        }
    }
}

struct AddressPickerView: View {
    @StateObject var viewModel: EventCreationViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var hasPublicAddress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            EventFlowTextField(title: "Where",
                               placeholder: "Tap to choose address",
                               footnote: "Shown only to approved guests",
                               input: $viewModel.queryFragment,
                               keyboardType: .default)
                .focused($isTextFieldFocused)
                .onTapGesture {
                    viewModel.isLocationSearchActive = true
                }
                .onChange(of: viewModel.isLocationSearchActive) { newValue in
                    isTextFieldFocused = newValue
                }
            
            if viewModel.isLocationSearchActive {
                LocationSearchResultsView(viewModel: viewModel)
            }
            
            Toggle("Set public address", isOn: $hasPublicAddress.animation())
                .font(.body)
                .fontWeight(.semibold)
                .tint(Color.theme.mixerIndigo)
                .padding(.bottom, 4)
            
            if hasPublicAddress {
                EventFlowTextField(title: "Public Address",
                                   placeholder: "e.g., Back Bay, Boston",
                                   footnote: "Loosely describe the area. Shown to all users",
                                   input: $viewModel.altAddress,
                                   keyboardType: .default)
                    .zIndex(2)
            }
            
            MapSnapshotView(location: $viewModel.selectedLocation)
                .cornerRadius(8)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

fileprivate struct LocationSearchResultsView: View {
    @StateObject var viewModel: EventCreationViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(viewModel.results, id: \.self) { result in
                    SearchResultsCell(title: result.title,
                                      subtitle: result.subtitle)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.selectLocation(result)
                        }
                    }
                }
            }
        }
    }
}
