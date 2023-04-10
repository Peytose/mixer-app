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
                        }

//                        + Text(" \(Image(systemName: "\(viewModel.visibility.icon)").font(.body))")
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

                    
                    HStack {
                        EventDetailRow(title: "Check-in Method",
                                       value: viewModel.checkInMethod2.rawValue)
                        
                        Image(systemName: viewModel.checkInMethod2 == .qrcode ? "qrcode" : "rectangle.and.pencil.and.ellipsis")
                            .font(.callout)
                    }
                }
                
                Divider().foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    EventDetailRow(title: "Starts",
                                   value: "\(Timestamp(date: viewModel.startDate).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                    
                    EventDetailRow(title: "Ends",
                                   value: "\(Timestamp(date: viewModel.endDate).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                    
                    if let deadline = viewModel.registrationDeadlineDate, viewModel.isRegistrationDeadlineEnabled {
                        EventDetailRow(title: "Deadline",
                                       value: "\(Timestamp(date: deadline).getTimestampString(format: "EEEE, MMM d + h:mm a").replacingOccurrences(of: "+", with: "at"))")
                    }
                    
                    EventDetailRow(title: "Location",
                                   value: viewModel.address)
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
                    
                    if viewModel.isManualApprovalEnabled {
                        EventOptionRow(text: "Manual approval enabled")
                    }
                    
                    if viewModel.isWaitlistEnabled {
                        EventOptionRow(text: "Waitlist pre-enabled")
                    }
                    
                    if viewModel.isGuestLimitEnabled {
                        EventOptionRow(text: "Guest limit: \(viewModel.guestLimit)")
                    }
                    
                    if viewModel.isMemberInviteLimitEnabled {
                        EventOptionRow(text: "Member invite limit: \(viewModel.memberInviteLimit)")
                    }
                    
                    if viewModel.isGuestInviteLimitEnabled {
                        EventOptionRow(text: "Guest invite limit: \(viewModel.guestInviteLimit)")
                    }
                    
                    if let method = viewModel.checkInMethod?.rawValue, viewModel.isCheckInOptionsEnabled {
                        EventOptionRow(text: "Check-in option: \(method)")
                    }
                    
                    EventOptionRow(text: "Bathrooms: \(viewModel.bathroomCount)")
                    
                }
                
//                if let image = image {
//                    Image(viewModel.image)
//                }
                
//                VStack(alignment: .center) {
//                    NextButton(text: "Create Event", action: viewModel.createEvent)
//                }
//                Image(viewModel.image)
                
            }
            .padding()
        }
        .background(Color.mixerBackground.ignoresSafeArea())
        .overlay(alignment: .bottom) {
            CreateEventNextButton(text: "Continue", action: viewModel.createEvent, isActive: true)
    }
    }
}

struct ReviewCreatedEventView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCreatedEventView(viewModel: CreateEventViewModel())
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

