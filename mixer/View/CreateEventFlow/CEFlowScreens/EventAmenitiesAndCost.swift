//
//  EventAmenitiesAndCost.swift
//  mixer
//
//  Created by Peyton Lyons on 3/21/23.
//

import SwiftUI
import Combine

struct EventAmenitiesAndCost: View {
    @State private var atTheDoorPrice: String = ""
    @State private var isFree: Bool = true
    @Binding var selectedAmenities: Set<EventAmenities>
    let action: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Attendance cost")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .top) {
                            CostOption(text: "Free Access",
                                       subtext: "All approved guests can enter the event free of charge.",
                                       icon: "hand.thumbsup.fill",
                                       iconColor: Color.green,
                                       isSelected: $isFree) { isFree = true }
                            
                            CostOption(text: "Paid Event",
                                       subtext: "Set the ticket price for guests to pay at the event entrance.",
                                       icon: "dollarsign",
                                       iconColor: Color.red,
                                       isSelected: $isFree.not) { isFree = false }
                        }
                        
                        LimitInputView(placeholder: "$0.00",
                                       amount: $atTheDoorPrice,
                                       isEnabled: $isFree.not)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Choose amenities")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(AmenityCategory.allCases, id: \.self) { category in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(category.rawValue)
                                    .textCase(.uppercase)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.mixerPurple)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(EventAmenities.allCases.filter { $0.category == category }, id: \.self) { amenity in
                                        Button {
                                            if selectedAmenities.contains(amenity) {
                                                selectedAmenities.remove(amenity)
                                            } else {
                                                selectedAmenities.insert(amenity)
                                            }
                                        } label: {
                                            HStack {
                                                Text(amenity.rawValue)
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white)
                                                Spacer()
                                                if selectedAmenities.contains(amenity) {
                                                    Image(systemName: amenity.icon)
                                                        .foregroundColor(Color.mixerPurple)
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 10)
                                        }
                                        
                                        if amenity.rawValue != EventAmenities.allCases.filter { $0.category == category }.last?.rawValue {
                                            Divider()
                                        }
                                    }
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 9)
                                        .fill(Color.mixerSecondaryBackground)
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .center) { NextButton(action: action) }
            }
            .padding()
        }
        .background(Color.mixerBackground.edgesIgnoringSafeArea(.all))
    }
    
}

struct EventAmenitiesAndCost_Previews: PreviewProvider {
    static var previews: some View {
        EventAmenitiesAndCost(selectedAmenities: .constant([])) {}
            .preferredColorScheme(.dark)
    }
}

fileprivate struct CostOption: View {
    let text: String
    let subtext: String
    let icon: String
    let iconColor: Color
    @Binding var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(iconColor)
                    .frame(width: 25, height: 25)
                
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtext)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 25, height: 25)
            }
            .padding()
            .background(alignment: .center) {
                RoundedRectangle(cornerRadius: 9)
                    .stroke(lineWidth: isSelected ? 2 : 1)
                    .foregroundColor(.mixerPurple.opacity(isSelected ? 1 : 0.75))
            }
            .frame(maxWidth: DeviceTypes.ScreenSize.width / 2.1)
        }
    }
}

fileprivate struct LimitInputView: View {
    let placeholder: String
    @Binding var amount: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: "ticket.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(isEnabled ? .white : .secondary)
                .frame(width: 20, height: 20)
            
            TextFieldDynamicWidth(title: placeholder, text: $amount)
                .lineLimit(1)
                .keyboardType(.decimalPad)
                .foregroundColor(isEnabled ? .white : .secondary)
                .font(.body)
                .fontWeight(.semibold)
                .onChange(of: amount) { newValue in
                    self.amount = newValue.formattedAsCurrency
                }
                .disabled(!isEnabled)
        }
        .padding()
        .background(alignment: .bottom) {
            Divider()
                .frame(height: isEnabled ? 2 : 1)
                .overlay(Color.mixerPurple.opacity(isEnabled ? 1 : 0.75))
        }
    }
}