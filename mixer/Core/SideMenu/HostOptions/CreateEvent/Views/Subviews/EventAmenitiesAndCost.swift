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
    @Binding var selectedAmenities: Set<EventAmenity>
    @Binding var bathroomCount: Int
    
    @State private var showAlert = false

    let action: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Choose Amenities")
                        .primaryHeading()
                    
                    InfoButton(action: { showAlert.toggle() })
                        .alert("Amenities", isPresented: $showAlert, actions: {}, message: { Text("Let your guests know what to expect before coming to your event. List important amenities like bathrooms, DJ, beer, water, etc...")})
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(AmenityCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.rawValue.capitalized)
                                .secondarySubheading()
                            
                            VStack(spacing: 0) {
                                ForEach(EventAmenity.allCases.filter { $0.category == category }, id: \.self) { amenity in
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
                                                .primaryActionButtonFont()
                                            
                                            Spacer()
                                            
                                            if amenity == EventAmenity.bathrooms {
                                                AmenityCountView(count: $bathroomCount)
                                                    .onChange(of: bathroomCount) { value in
                                                        if value > 0 {
                                                            selectedAmenities.insert(EventAmenity.bathrooms)
                                                        } else if value == 0 {
                                                            selectedAmenities.remove(EventAmenity.bathrooms)
                                                        }
                                                    }
                                            } else if selectedAmenities.contains(amenity) {
                                                Image(systemName: "checkmark")
                                                    .fontWeight(.medium)
                                                    .foregroundColor(Color.theme.mixerPurple)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                    }
                                    
                                    if amenity.rawValue != EventAmenity.allCases.filter({ $0.category == category }).last?.rawValue {
                                        Divider()
                                    }
                                }
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.theme.secondaryBackgroundColor)
                            }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color.theme.backgroundColor)
    }
}

//struct EventAmenityAndCost_Previews: PreviewProvider {
//    static var previews: some View {
//        EventAmenityAndCost(viewModel: EventCreationViewModel(), selectedAmenities: .constant([]), bathroomCount: .constant(0)) {}
//            .preferredColorScheme(.dark)
//    }
//}

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
