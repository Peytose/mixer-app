//
//  EventAmenitiesAndCost.swift
//  mixer
//
//  Created by Peyton Lyons on 3/21/23.
//

import SwiftUI
import Combine

struct EventAmenitiesAndCost: View {
    @ObservedObject var viewModel: CreateEventViewModel
    
    @Binding var selectedAmenities: Set<EventAmenities>
    @Binding var bathroomCount: Int
    
    @State private var showAlert = false

    let action: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Choose Amenities")
                        .heading()
                    
                    InfoButton(action: { showAlert.toggle() })
                        .alert("Amenities", isPresented: $showAlert, actions: {}, message: { Text("Let your guests know what to expect before coming to your event. List important amenities like bathrooms, DJ, beer, water, etc...")})
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(AmenityCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.rawValue.capitalized)
                                .subheading2()
                            
                            VStack(spacing: 0) {
                                ForEach(EventAmenities.allCases.filter { $0.category == category }, id: \.self) { amenity in
                                    Button {
                                        if selectedAmenities.contains(amenity) {
                                            if amenity != .bathrooms {
                                                selectedAmenities.remove(amenity)
                                            }
                                        } else {
                                            if amenity != .bathrooms {
                                                selectedAmenities.insert(amenity)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            if amenity == .beer {
                                                Text("🍺")
                                            } else if amenity == .water {
                                                Text("💦")
                                            } else if amenity == .smokingArea {
                                                Text("🚬")
                                            } else if amenity == .dj {
                                                Text("🎧")
                                            } else if amenity == .coatCheck {
                                                Text("🧥")
                                            } else if amenity == .nonAlcohol {
                                                Text("🧃")
                                            } else if amenity == .food {
                                                Text("🍕")
                                            } else if amenity == .danceFloor {
                                                Text("🕺")
                                            } else if amenity == .snacks {
                                                Text("🍪")
                                            } else if amenity == . drinkingGames{
                                                Text("🏓")
                                            } else {
                                                Image(systemName: amenity.icon)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text(amenity.rawValue)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            if amenity == EventAmenities.bathrooms {
                                                AmenityCountView(count: $bathroomCount)
                                                    .onChange(of: bathroomCount) { value in
                                                        if value > 0 {
                                                            selectedAmenities.insert(EventAmenities.bathrooms)
                                                        } else if value == 0 {
                                                            selectedAmenities.remove(EventAmenities.bathrooms)
                                                        }
                                                    }
                                            } else if selectedAmenities.contains(amenity) {
                                                Image(systemName: "checkmark")
                                                    .fontWeight(.medium)
                                                    .foregroundColor(Color.mixerPurple)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                    }
                                    
                                    if amenity.rawValue != EventAmenities.allCases.filter({ $0.category == category }).last?.rawValue {
                                        Divider()
                                    }
                                }
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.mixerSecondaryBackground)
                            }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color.mixerBackground)
        .overlay(alignment: .bottom) {
            CreateEventNextButton(text: "Continue", action: action, isActive: true)
        }
    }
}

struct EventAmenitiesAndCost_Previews: PreviewProvider {
    static var previews: some View {
        EventAmenitiesAndCost(viewModel: CreateEventViewModel(), selectedAmenities: .constant([]), bathroomCount: .constant(0)) {}
            .preferredColorScheme(.dark)
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
