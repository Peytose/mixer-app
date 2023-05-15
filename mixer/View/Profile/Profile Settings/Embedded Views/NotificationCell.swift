//
//  NotificationCell.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI
import Kingfisher

struct NotificationCell: View {
    @Binding var notification: Notification

    var body: some View {
        HStack {
            KFImage(URL(string: notification.profileImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .padding(.trailing, 5)
            
            VStack(alignment: .leading) {
                Text(notification.username)
                    .fontWeight(.semibold) +
                Text(notification.type.notificationMessage)
                    .foregroundColor(.secondary) +
                Text(" \(notification.timestamp.notificationTimeString())")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            .minimumScaleFactor(0.9)
            
            Spacer()
            
            switch notification.type {
            case .acceptFriend:
                Text("")
                
            case .likedEvent:
                Text("Liked Event")
                
            case .requestFriend:
                HStack(alignment: .center, spacing: 10) {
                    ActionButton(text: "Accept", color: Color.mixerIndigo) {
                        NotificationsViewModel.acceptFriendRequest(notification: notification) {
                            DispatchQueue.main.async {
                                print("DEBUG: Accept friend request button pressed!")
                                notification.type = .acceptFriend
                                notification.hasBeenSeen = true
                            }
                        }
                    }
                    
                    ActionButton(text: "Reject", color: Color.mixerSecondaryBackground) {
                        NotificationsViewModel.cancelFriendRequest(notification: notification)
                    }
                }
                .padding(.leading, 20)
            }
        }
        .frame(maxHeight: 60)
        .onAppear {
            if notification.type == .acceptFriend && !notification.hasBeenSeen {
                notification.hasBeenSeen = true
                NotificationsViewModel.updateHasSeen(notification)
            }
        }
        .onChange(of: notification.type) { newValue in
            if newValue != .requestFriend && !notification.hasBeenSeen {
                notification.hasBeenSeen = true
                NotificationsViewModel.updateHasSeen(notification)
            }
        }
    }
}

struct ActionButton: View {
    let text: String
    let color: Color
    
    let action: () -> Void
    
    var body: some View {
        Button(action: { action() }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 70, height: 30)
                .overlay {
                    Text(text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
        }
    }
}
