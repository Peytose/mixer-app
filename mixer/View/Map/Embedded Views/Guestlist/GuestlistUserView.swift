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
    @ObservedObject var viewModel: GuestlistViewModel
    @State var guest: EventGuest

    var body: some View {
        VStack {
            if let imageUrl = guest.profileImageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: DeviceTypes.ScreenSize.width * 0.50, height: DeviceTypes.ScreenSize.width * 0.50)
                    .padding(.top)
            } else {
                Image("default-avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: DeviceTypes.ScreenSize.width * 0.50, height: DeviceTypes.ScreenSize.width * 0.50)
                    .padding(.top)
            }
            
            HStack(alignment: .bottom) {
                Text(guest.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if let age = guest.age {
                    Text("\(age)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "graduationcap.fill")
                    .imageScale(.small)
                    .padding(.trailing, -6)
                
                Text(guest.university)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 50) {
                if let name = guest.checkedInBy, let time = guest.timestamp?.getTimestampString(format: "h:mm a") {
                    VStack(alignment: .center, spacing: 0) {
                        Text("Checked in by")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .center, spacing: 5) {
                            Text(name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(time)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let name = guest.invitedBy {
                    VStack(alignment: .center, spacing: 0) {
                        Text("Invited by")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                
                if let gender = guest.gender {
                    VStack(alignment: .center, spacing: 0) {
                        Text("Gender")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(gender)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
            }
            .font(.title3.weight(.semibold))
            .padding(2)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .top)
        .background(Color.mixerBackground)
        .preferredColorScheme(.dark)
        .overlay(alignment: .bottom) {
            Button {
                if guest.status == .invited {
                    viewModel.checkIn(guest: &guest)
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
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(radius: 5, y: 10)
            }
        }
     }
}

struct GuestlistUserView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistUserView(viewModel: GuestlistViewModel(event: CachedEvent(from: Mockdata.event)), guest: EventGuest(name: "Peyton Lyons", university: "MIT", age: 20, gender: "Male", status: GuestStatus.checkedIn, invitedBy: "Jose", timestamp: Timestamp()))
    }
}

