//
//  GuestDetailView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/12/23.
//

import SwiftUI
import Firebase
import Kingfisher

struct GuestDetailView: View {
    @EnvironmentObject var viewModel: GuestlistViewModel
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            if let guest = viewModel.selectedGuest {
                VStack(alignment: .center, spacing: 10) {
                    userInfoSection(guest: guest)
                    
                    invitationAndCheckInSection(guest: guest)
                    
                    Spacer()
                    
                    actionButton(guest: guest)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top)
            }
        }
    }
}

private extension GuestDetailView {
    @ViewBuilder
    func userInfoSection(guest: EventGuest) -> some View {
        VStack {
            AvatarView(url: guest.profileImageUrl, size: DeviceTypes.ScreenSize.width * 0.5)
            
            VStack(alignment: .center, spacing: 7) {
                Text(guest.name)
                    .primarySubheading()
                    .multilineTextAlignment(.center)
                
                if let age = guest.age {
                    Text("\(age)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .imageScale(.small)
                    
                    Text(guest.university)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Text("Gender: \(guest.gender.description)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    
    @ViewBuilder
    func invitationAndCheckInSection(guest: EventGuest) -> some View {
        VStack {
            if let name = guest.invitedBy {
                HStack {
                    Text("Invited by: \(name)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            if let name = guest.checkedInBy, let time = guest.timestamp?.getTimestampString(format: "h:mm a") {
                HStack {
                    Text("Checked in by \(name) at \(time)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
    
    
    @ViewBuilder
    func actionButton(guest: EventGuest) -> some View {
        Button {
            if guest.status == .invited {
                viewModel.checkIn()
            } else {
                viewModel.remove()
            }
        } label: {
            Capsule()
                .fill(Color.theme.secondaryBackgroundColor)
                .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                .shadow(radius: 20, x: -8, y: -8)
                .shadow(radius: 20, x: 8, y: 8)
                .overlay {
                    HStack {
                        Image(systemName: guest.status == .invited ? "list.clipboard" : "person.badge.minus")
                            .imageScale(.large)
                            .foregroundColor(.white)
                        
                        Text("\(guest.status == .invited ? "Check in" : "Remove") \(guest.name)")
                            .body(color: .white)
                    }
                }
                .shadow(radius: 5, y: 10)
        }
    }
}
