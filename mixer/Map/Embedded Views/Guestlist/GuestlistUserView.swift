//
//  GuestlistUserView.swift
//  mixer
//
//  Created by Jose Martinez on 1/19/23.
//

import SwiftUI
import Firebase
import Kingfisher

struct GuestlistUserView: View {
    @EnvironmentObject var viewModel: GuestlistViewModel
    
    var body: some View {
        if let guest = viewModel.selectedGuest {
            VStack(alignment: .center, spacing: 10) {
                AvatarView(url: guest.profileImageUrl,
                           size: DeviceTypes.ScreenSize.width * 0.5)
                
                VStack(alignment: .center, spacing: 7) {
                    HStack(alignment: .center) {
                        Text(guest.name)
                            .primarySubheading()
                            .multilineTextAlignment(.center)
                        
                        if let age = guest.age {
                            Text("\(age)")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .imageScale(.small)
                        
                        Text(guest.university)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(alignment: .center) {
                    if let name = guest.invitedBy {
                        VStack(alignment: .leading) {
                            Text("Invited by")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(name)
                                .primarySubheading()
                        }
                    }
                    
                    Spacer()
                    
                    if let gender = guest.gender {
                        VStack(alignment: .trailing) {
                            Text("Gender")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(gender)
                                .primarySubheading()
                        }
                    }
                }
                .padding(.horizontal)
                
                if let name = guest.checkedInBy, let time = guest.timestamp?.getTimestampString(format: "h:mm a") {
                    HStack(alignment: .center) {
                        Text("Checked in by")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(name)
                            .primarySubheading()
                        
                        Text(time)
                            .footnote()
                    }
                }
            }
            .frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .top)
            .padding(.top)
            .background(Color.mixerBackground)
            .preferredColorScheme(.dark)
            .overlay(alignment: .bottom) {
                Button {
                    if guest.status == .invited {
                        viewModel.checkIn(guest: guest)
                    } else {
                        viewModel.remove(guest: guest)
                    }
                } label: {
                    Capsule()
                        .fill(Color.mixerSecondaryBackground)
                        .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                        .shadow(radius: 20, x: -8, y: -8)
                        .shadow(radius: 20, x: 8, y: 8)
                        .overlay {
                            HStack {
                                Image(systemName: guest.status == .invited ? "list.clipboard" : "person.badge.minus")
                                    .imageScale(.large)
                                    .foregroundColor(.mainFont)
                                
                                Text("\(guest.status == .invited ? "Check in" : "Remove") \(guest.name)")
                                    .body(color: .white)
                            }
                        }
                        .shadow(radius: 5, y: 10)
                }
            }
        }
    }
}
