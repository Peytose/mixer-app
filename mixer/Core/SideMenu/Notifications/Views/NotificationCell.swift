//
//  NotificationCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import Kingfisher

struct NotificationCell: View {
    @ObservedObject var cellViewModel: NotificationCellViewModel
    var isFollowed: Bool { return cellViewModel.notification.isFollowed ?? false }
    @Namespace var namespace
    @Binding var path: NavigationPath
    
    init(cellViewModel: NotificationCellViewModel,
         path: Binding<NavigationPath>) {
        self.cellViewModel = cellViewModel
        self._path         = path
    }
    
    var body: some View {
        HStack {
            Button {
                cellViewModel.deleteNotification()
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
            }
            
            ZStack {
                KFImage(URL(string: cellViewModel.notification.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                NavigationLink(value: cellViewModel.notification.type) {
                    Text("")
                        .opacity(0)
                }
            }
            .frame(width: 40, height: 40)
            
            Group {
                cellViewModel.formattedNotificationMessage()
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Side button(s)
            Group {
                switch cellViewModel.notification.type {
                case .friendRequest:
                    HStack {
                        ListCellActionButton(text: "Accept",
                                                 action: cellViewModel.acceptFriendRequest)
                        
                        ListCellActionButton(text: "Decline",
                                                 isSecondaryLabel: true,
                                                 action: cellViewModel.cancelRequestOrRemoveFriend)
                    }
                case .newFollower:
                    if let user = cellViewModel.notification.user {
                        NotificationSecondaryImage(imageUrl: user.profileImageUrl) {
                            ProfileView(user: user, path: $path)
                        }
                    }
                case .memberInvited:
                    HStack {
                        ListCellActionButton(text: "Join",
                                                 action: cellViewModel.acceptMemberInvite)
                        
                        ListCellActionButton(text: "Reject",
                                                 isSecondaryLabel: true,
                                                 action: cellViewModel.declineMemberInvite)
                    }
                case .eventLiked:
                    if let event = cellViewModel.notification.event {
                        NotificationSecondaryImage(imageUrl: event.eventImageUrl) {
                            EventDetailView(event: event, path: $path)
                        }
                    }
                case .guestlistJoined:
                    ListCellActionButton(text: "Remove",
                                             action: cellViewModel.removeFromGuestlist)
                case .guestlistAdded:
                    if let event = cellViewModel.notification.event {
                        NotificationSecondaryImage(imageUrl: event.eventImageUrl) {
                            EventDetailView(event: event, path: $path)
                        }
                    }
                default: Text("")
                }
            }
        }
        .padding(.horizontal)
    }
}

fileprivate struct NotificationSecondaryImage<Content: View>: View {
    let imageUrl: String
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipped()
            
            NavigationLink { content } label: {
                Text("")
                    .opacity(0)
            }
        }
        .frame(width: 40, height: 40)
    }
}

extension NotificationCell {
    var backArrowButton: some View {
        Button { path.removeLast() } label: {
            Image(systemName: "arrow.left")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
}
