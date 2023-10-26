//
//  NotificationCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import Kingfisher

struct NotificationCell: View {
    @ObservedObject var notificationsViewModel: NotificationsViewModel
    @StateObject var cellViewModel: NotificationCellViewModel
    var isFollowed: Bool { return cellViewModel.notification.isFollowed ?? false }
    @Namespace var namespace
    
    init(notificationsViewModel: NotificationsViewModel,
         notification: Notification) {
        self.notificationsViewModel = notificationsViewModel
        _cellViewModel              = StateObject(wrappedValue: NotificationCellViewModel(notification: notification))
    }
    
    var body: some View {
        HStack {
            if notificationsViewModel.isEditing {
                Image(systemName: notificationsViewModel.selectedNotificationIds.contains(where: { $0 == cellViewModel.notification.id }) ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(notificationsViewModel.selectedNotificationIds.contains(where: { $0 == cellViewModel.notification.id }) ? Color.theme.mixerIndigo : .white)
            }
            
            NavigationLink(value: cellViewModel.notification) {
                KFImage(URL(string: cellViewModel.notification.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .padding(.trailing, 5)
            .disabled(notificationsViewModel.isEditing)
            
            Group {
                cellViewModel.formattedNotificationMessage()
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Side button(s)
            if !notificationsViewModel.isEditing {
                Group {
                    switch cellViewModel.notification.type {
                    case .friendRequest:
                        HStack {
                            ListCellActionButton(text: "Accept",
                                                 action: cellViewModel.acceptFriendRequest)
                            
                            ListCellActionButton(text: "Decline",
                                                 isSecondaryLabel: true,
                                                 action: cellViewModel.cancelOrDeleteRelationship)
                        }
                    case .newFollower:
                        if let user = cellViewModel.notification.user {
                            NotificationSecondaryImage(imageUrl: user.profileImageUrl) {
                                ProfileView(user: user)
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
                                EventDetailView(event: event)
                            }
                        }
                    case .guestlistJoined:
                        ListCellActionButton(text: "Remove",
                                             action: cellViewModel.removeFromGuestlist)
                    case .guestlistAdded:
                        if let event = cellViewModel.notification.event {
                            NotificationSecondaryImage(imageUrl: event.eventImageUrl) {
                                EventDetailView(event: event)
                            }
                        }
                    case .plannerInvited, .plannerPendingReminder:
                        HStack {
                            ListCellActionButton(text: "Accept",
                                                 action: cellViewModel.acceptPlannerInvite)
                            
                            ListCellActionButton(text: "Decline",
                                                 isSecondaryLabel: true,
                                                 action: cellViewModel.declinePlannerInvite)
                        }
                    case .plannerDeclined:
                        ListCellActionButton(text: "Remove",
                                             action: cellViewModel.removePlanner)
                    default: Text("")
                    }
                }
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            if notificationsViewModel.isEditing {
                notificationsViewModel.selectNotification(cellViewModel.notification)
            }
        }
    }
}

fileprivate struct NotificationSecondaryImage<Content: View>: View {
    let imageUrl: String
    @ViewBuilder let content: Content
    
    var body: some View {
        NavigationLink { content } label: {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipped()
        }
    }
}
