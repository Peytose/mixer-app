//
//  GuestListUserView.swift
//  mixer
//
//  Created by Jose Martinez on 1/19/23.
//

import SwiftUI
import Firebase

struct GuestListUserView: View {
    @ObservedObject var parentViewModel: GuestlistViewModel
    var guest: EventGuest

    var body: some View {
        VStack {
            Image("mock-user-1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: DeviceTypes.ScreenSize.width * 0.50, height: DeviceTypes.ScreenSize.width * 0.50)
                .padding(.top)
            
            HStack(alignment: .bottom) {
                Text(guest.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(String(guest.age!))
                    .font(.title3)
                    .foregroundColor(.secondary)
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
                VStack(alignment: .center, spacing: 0) {
                    Text(guest.invitedBy!)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Invited by")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Text(guest.gender!)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Gender")
                        .font(.headline)
                        .foregroundColor(.secondary)
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
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                parentViewModel.checkIn(guest: guest)
            } label: {
                Capsule()
                    .fill(Color.mixerSecondaryBackground)
                    .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                    .shadow(radius: 20, x: -8, y: -8)
                    .shadow(radius: 20, x: 8, y: 8)
                    .overlay {
                        HStack {
                            Image(systemName: "list.clipboard")
                                .imageScale(.large)
                                .foregroundColor(.mainFont)
                            
                            Text("Check \(guest.name) in")
                                .font(.body.weight(.medium))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(radius: 5, y: 10)
            }
        }
     }
}

struct GuestListUserView_Previews: PreviewProvider {
    static var previews: some View {
//        GuestListUserView(user: EventGuest(name: "Jose", university: "MIT"))
        GuestListUserView(parentViewModel: GuestlistViewModel(event: CachedEvent(from: Mockdata.event)), guest: EventGuest(name: "Peyton Lyons", university: "MIT", age: 20, gender: "Male", status: GuestStatus.attending, invitedBy: "Jose", timestamp: Timestamp()))
    }
}

