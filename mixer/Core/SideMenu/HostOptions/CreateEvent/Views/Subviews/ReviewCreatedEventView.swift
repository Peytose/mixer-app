//
//  ReviewCreatedEventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct ReviewCreatedEventView: View {
    @EnvironmentObject var viewModel: EventCreationViewModel
    @State private var showAllAmenities = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2.5) {
                        Text(viewModel.title)
                            .primaryHeading()
                        
                        eventTypeAndPreview
                    }
                    
                    Text("Basic Info")
                        .primaryHeading()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        EventDetailRow(title: "Event Type",
                                       value: viewModel.type.description)
                        
                        HStack(alignment: .center) {
                            Text("Description:")
                                .secondarySubheading()
                            
                            Spacer()
                            
                            Text(viewModel.eventDescription)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        if viewModel.note != "" {
                            HStack(alignment: .center) {
                                Text("Note")
                                    .secondarySubheading()
                                
                                Spacer()
                                
                                Text(viewModel.note)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                }
                
                Divider().foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Settings")
                        .primaryHeading()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            EventDetailRow(title: "Visibility",
                                           value: viewModel.isPrivate ? "Private" : "Public")
                        }
                        
                        HStack {
                            EventDetailRow(title: "Privacy",
                                           value: viewModel.isInviteOnly ? "Invite Only" : "Open")
                        }
                        
                        HStack {
                            EventDetailRow(title: "Check-in Option",
                                           value: viewModel.isCheckInViaMixer ? "Via mixer" : "Out-of-app")
                        }
                    }
                }
                
                Divider().foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location & Dates")
                        .primaryHeading()
                    VStack (alignment: .leading, spacing: 4) {
                        EventDetailRow(title: "Starts",
                                       value: "\(Timestamp(date: viewModel.startDate).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                        
                        EventDetailRow(title: "Ends",
                                       value: "\(Timestamp(date: viewModel.endDate).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                        
                        // MARK: Will be added
//                        if let deadline = viewModel.cutOffDate {
//                            EventDetailRow(title: "Deadline",
//                                           value: "\(Timestamp(date: deadline).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
//                        }
                        
                        if viewModel.altAddress != "" {
                            EventDetailRow(title: "Public Address",
                                           value: viewModel.altAddress,
                                           alignment: .top)
                        }
                        

                        if let address = viewModel.selectedLocation?.title {
                            EventDetailRow(title: "Location",
                                           value: address,
                                           alignment: .top)
                        }
                    }
                }
                
                Divider().foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Other")
                        .primaryHeading()
                    
                    VStack (alignment: .leading, spacing: 4) {
                        if let cost = viewModel.cost {
                            EventOptionRow(icon: "dollarsign.circle.fill",
                                           color: .red,
                                           text: "\(cost)")
                        } else {
                            EventOptionRow(icon: "hand.thumbsup.circle.fill",
                                           color: .green,
                                           text: "Free")
                        }
                        
                        if viewModel.isManualApprovalEnabled {
                            EventOptionRow(text: "Manual approval enabled")
                        }
                        
                        if viewModel.guestLimitStr != "" {
                            EventOptionRow(text: "Guest limit: \(viewModel.guestLimitStr)")
                        }
                        
                        if viewModel.memberInviteLimitStr != "" {
                            EventOptionRow(text: "Member invite limit: \(viewModel.memberInviteLimitStr)")
                        }
                        
                        EventOptionRow(text: "Bathrooms: \(viewModel.bathroomCount)")
                        
                        if !viewModel.selectedAmenities.isEmpty {
                            amenitiesView
                                .padding(.top)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Flyer")
                        .primaryHeading()
                    
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(width: 200, height: 200)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        VStack {
                            Text("Event Flyer")
                                .primarySubheading()
                            
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
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color.theme.backgroundColor)
    }
    
    var eventTypeAndPreview: some View {
        HStack(spacing: 5) {
            Text(viewModel.isPrivate ? "Private" : "Public")
            
            + Text(viewModel.isInviteOnly ? " Invite Only " : " Open ")
            
            + Text(viewModel.type.description)
            
            Image(systemName: viewModel.isPrivate ? "lock.fill" : "globe")
                .font(.subheadline)
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
                    
                    VStack(alignment: .leading) {
                        ForEach(EventAmenity.allCases, id: \.self) { amenity in
                            if viewModel.selectedAmenities.contains(amenity) {
                                HStack {
                                    amenity.displayIcon
                                        .font(.headline)
                                        .padding(.trailing, 5)
                                    
                                    Text(amenity.rawValue)
                                        .font(.headline)
                                        .fontWeight(.regular)
                                    
                                    Spacer()
                                }
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
                                    .foregroundColor(.white)
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
                                    .foregroundColor(.white)
                                    .frame(width: 350, height: 45)
                                    .overlay {
                                        Text(showAllAmenities ? "Show less" : "Show all \(viewModel.selectedAmenities.count ) amenities")
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
    var alignment: VerticalAlignment = .center
    
    var body: some View {
        HStack(alignment: alignment) {
            Text("\(title):")
                .secondarySubheading()
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

