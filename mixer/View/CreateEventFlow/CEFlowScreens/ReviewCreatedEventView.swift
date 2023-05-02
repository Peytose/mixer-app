//
//  ReviewCreatedEventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ReviewCreatedEventView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    var namespace: Namespace.ID
    @State var showPreview      = false
    @State var showAllAmenities = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2.5) {
                            Text(viewModel.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                
                        HStack(spacing: 5) {
                            Text("\(viewModel.visibility.rawValue) \(viewModel.privacy.rawValue) Event")
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Image(systemName: "\(viewModel.visibility.icon)")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Button("Preview Event", action: { showPreview.toggle() })
                                .fontWeight(.semibold)
                                .foregroundColor(.mixerIndigo)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2.5) {
                        Text("Description")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(viewModel.description)
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider().foregroundColor(.secondary)
                    
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        EventDetailRow(title: "Visibility",
                                       value: viewModel.visibility.rawValue)
                        
                        Image(systemName: viewModel.visibility == ._public ? "globe" : "lock")
                            .font(.callout)
                    }

                    HStack {
                        EventDetailRow(title: "Privacy",
                                       value: viewModel.privacy.rawValue)
                        
                        Image(systemName: viewModel.privacy == .inviteOnly ? "envelope" : "envelope.open")
                            .font(.callout)
                    }

                    if let checkInMethod = viewModel.checkInMethod {
                        HStack {
                            EventDetailRow(title: "Check-in Method",
                                           value: checkInMethod.rawValue)
                            
                            Image(systemName: checkInMethod.icon)
                                .font(.callout)
                        }
                    }
                }
                
                Divider().foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    EventDetailRow(title: "Starts",
                                   value: "\(Timestamp(date: viewModel.startDate).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                    
                    EventDetailRow(title: "Ends",
                                   value: "\(Timestamp(date: viewModel.endDate).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                    
                    if let deadline = viewModel.registrationDeadlineDate, viewModel.eventOptions[EventOption.isRegistrationDeadlineEnabled.rawValue] ?? false {
                        EventDetailRow(title: "Deadline",
                                       value: "\(Timestamp(date: deadline).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                    }
                    
                    if viewModel.eventOptions[EventOption.hasPublicAddress.rawValue] ?? false {
                        HStack(alignment: .top) {
                            Text("Public Address:")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(viewModel.publicAddress)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("Location:")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(viewModel.address)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider().foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    if let cost = viewModel.cost {
                        EventOptionRow(icon: "dollarsign.circle.fill",
                                       color: .red,
                                       text: "\(cost)")
                    } else {
                        EventOptionRow(icon: "hand.thumbsup.circle.fill",
                                       color: .green,
                                       text: "Free")
                    }
                    
                    if viewModel.eventOptions[EventOption.isManualApprovalEnabled.rawValue] ?? false {
                        EventOptionRow(text: "Manual approval enabled")
                    }
                    
                    if viewModel.eventOptions[EventOption.isWaitlistEnabled.rawValue] ?? false {
                        EventOptionRow(text: "Waitlist pre-enabled")
                    }
                    
                    if viewModel.eventOptions[EventOption.isGuestLimitEnabled.rawValue] ?? false {
                        EventOptionRow(text: "Guest limit: \(viewModel.guestLimit)")
                    }
                    
                    if viewModel.eventOptions[EventOption.isMemberInviteLimitEnabled.rawValue] ?? false {
                        EventOptionRow(text: "Member invite limit: \(viewModel.memberInviteLimit)")
                    }
                    
                    if viewModel.eventOptions[EventOption.isGuestInviteLimitEnabled.rawValue] ?? false {
                        EventOptionRow(text: "Guest invite limit: \(viewModel.guestInviteLimit)")
                    }
                    
                    if let method = viewModel.checkInMethod?.rawValue, viewModel.eventOptions[EventOption.isCheckInEnabled.rawValue] ?? false {
                        EventOptionRow(text: "Check-in option: \(method)")
                    }
                    
                    EventOptionRow(text: "Bathrooms: \(viewModel.bathroomCount)")
                    if (viewModel.selectedAmenities) != nil {
                        amenitiesView
                    }
                }
                
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .frame(width: 200, height: 200)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack {
                        Text("Event Flyer")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    VStack {
                        Text("Event Flyer")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                    }
                    .frame(maxWidth: DeviceTypes.ScreenSize.width,
                           minHeight: DeviceTypes.ScreenSize.height / 5)
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color.mixerBackground.ignoresSafeArea())
        .overlay(alignment: .bottom) {
            CreateEventNextButton(text: "Continue",
                                  action: viewModel.createEvent,
                                  isActive: true)
    }
        .sheet(isPresented: $showPreview) {
            EventPreviewView(viewModel: viewModel, namespace: namespace)
        }
    }
    var amenitiesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if showAllAmenities && !viewModel.selectedAmenities.isEmpty {
                    Text("Amenities")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                
                ForEach(EventAmenities.allCases, id: \.self) { amenity in
                    if viewModel.selectedAmenities.contains(amenity) {
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
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
                
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(dampingFraction: 0.8)) {
                            showAllAmenities.toggle()
                        }
                    } label: {
                        ZStack {
                            if viewModel.selectedAmenities.isEmpty {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.DesignCodeWhite)
                                    .frame(width: 350, height: 45)
                                    .overlay {
                                        Text("No Amenities Selected")
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                    }
                                    .disabled(true)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.DesignCodeWhite)
                                    .frame(width: 350, height: 45)
                                    .overlay {
                                        Text(showAllAmenities ? "Show less" : "Show all \(viewModel.selectedAmenities.count ?? 0) amenities")
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                    }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct ReviewCreatedEventView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ReviewCreatedEventView(viewModel: CreateEventViewModel(), namespace: namespace)
            .preferredColorScheme(.dark)
    }
}

fileprivate struct EventOptionRow: View {
    @State var icon: String = "checkmark.circle.fill"
    @State var color: Color = .white
    let text: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icon)
                .resizable()
                .foregroundColor(color)
                .frame(width: 23, height: 23)
            
            Text(text)
                .font(.headline)
                .fontWeight(.regular)
                .foregroundColor(.white)
        }
    }
}

fileprivate struct EventDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(title):")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

