//
//  EventAmenityAndCost.swift
//  mixer
//
//  Created by Peyton Lyons on 3/21/23.
//

import SwiftUI
import Combine

struct EventAmenityAndCost: View {
    @EnvironmentObject var viewModel: EventCreationViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Tap to choose amenities!")
                        .primaryHeading()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    InfoButton { viewModel.alertItem = AlertContext.aboutAmenitiesInfo }
                }
                .padding(.bottom, 15)
                
                ToggleAmenityView(viewModel: viewModel)
            }
            .padding()
            .padding(.bottom, 80)
            .background(Color.theme.backgroundColor)
        }

    }
}


struct ToggleAmenityView<ViewModel: AmenityHandling>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ForEach(AmenityCategory.allCases, id: \.self) { category in
            let amenitiesInCategory = EventAmenity.allCases.filter { $0.category == category }
            if !amenitiesInCategory.isEmpty {
                Section {
                    VStack(alignment: .leading) {
                        ForEach(amenitiesInCategory, id: \.self) { amenity in
                            Button { toggleAmenity(amenity) } label: {
                                HStack {
                                    amenity.displayIcon
                                        .padding(2)
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .padding(.trailing, 5)
                                    
                                    Text(amenity.rawValue)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    accessoryView(for: amenity)
                                }
                                .padding(.horizontal)
                                .foregroundColor(.white)
                            }
                            
                            if amenitiesInCategory.last != amenity {
                                Divider()
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 50)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                    .padding(.vertical)
                    .background {
                        Color.theme.secondaryBackgroundColor
                            .cornerRadius(10)
                    }
                } header: {
                    Text(category.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                        .padding(.bottom, 2)
                }
            }
        }
    }
    
    @ViewBuilder
    private func accessoryView(for amenity: EventAmenity) -> some View {
        if amenity == .bathrooms {
            AmenityCountView(count: $viewModel.bathroomCount)
        } else if viewModel.selectedAmenities.contains(amenity) {
            Image(systemName: "checkmark")
                .fontWeight(.medium)
                .foregroundColor(Color.theme.mixerPurple)
        } else {
            EmptyView()
        }
    }
    
    
    private func toggleAmenity(_ amenity: EventAmenity) {
        guard amenity != .bathrooms else { return }

        if viewModel.selectedAmenities.contains(amenity) {
            viewModel.selectedAmenities.remove(amenity)
        } else {
            viewModel.selectedAmenities.insert(amenity)
        }

        viewModel.containsAlcohol = viewModel.selectedAmenities.contains(.alcohol) || viewModel.selectedAmenities.contains(.beer)
    }
}

fileprivate struct AmenityCountView: View {
    @Binding var count: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Button(action: {
                subtract()
            }, label: {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 25, height: 25)
                    .cornerRadius(6)
                    .overlay {
                        Image(systemName: "minus")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
            })
            
            Text(String(count))
                .foregroundColor(.white)
            
            Button(action: {
                add()
            }, label: {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 25, height: 25)
                    .cornerRadius(6)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
            })
        }
    }
    
    func add() {
        count += 1
    }
    
    func subtract() {
        if count > 0 {
            count -= 1
        }
    }
}
