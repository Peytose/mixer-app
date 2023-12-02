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
                    
                    actionButton()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top)
                .onAppear {
                    print("DEBUG: guest status: \(guest.status.description)")
                }
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
                
                if let university = guest.university, let icon = university.icon {
                    HStack {
                        Image(systemName: icon)
                            .imageScale(.small)
                        
                        Text(university.shortName ?? university.name)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
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
    func actionButton() -> some View {
        Button {
            print("DEBUG: status: \(viewModel.selectedGuest?.status)")
            
            switch viewModel.selectedGuest?.status {
            case .checkedIn:
                viewModel.remove()
            case .invited:
                viewModel.checkIn()
            case .requested:
                viewModel.approveGuest()
            case .none:
                break
            }
        } label: {
            Capsule()
                .fill(Color.theme.secondaryBackgroundColor)
                .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                .shadow(radius: 20, x: -8, y: -8)
                .shadow(radius: 20, x: 8, y: 8)
                .overlay {
                    HStack {
                        Image(systemName: viewModel.selectedGuest?.status.icon ?? "")
                            .imageScale(.large)
                            .foregroundColor(.white)
                        
                        Text(viewModel.selectedGuest?.status.guestlistButtonTitle ?? "")
                            .body(color: .white)
                    }
                }
                .shadow(radius: 5, y: 10)
        }
    }
}
