//
//  NotificationsView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                LazyVStack(alignment: .center) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationCell(notificationsViewModel: viewModel,
                                         notification: notification)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 10)
            .navigationDestination(for: Notification.self) { notification in
                switch notification.type {
                case .friendAccepted,
                        .friendRequest,
                        .newFollower,
                        .memberJoined,
                        .guestlistJoined:
                    if let user = notification.user {
                        ProfileView(user: user)
                    }
                case .memberInvited,
                        .guestlistAdded:
                    if let host = notification.host {
                        HostDetailView(host: host)
                    }
                case .eventLiked:
                    if let event = notification.event {
                        EventDetailView(event: event)
                    }
                }
            }
        }
        .navigationBar(title: "Notifications", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isEditing {
                    XDismissButton {
                        viewModel.isEditing.toggle()
                        viewModel.selectedNotificationIds = []
                    }
                } else {
                    PresentationBackArrowButton()
                }
            }
            
            if !viewModel.notifications.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditNotificationsButton(viewModel: viewModel)
                }
            }
        }
        .onAppear { viewModel.saveCurrentTimestamp() }
    }
}

fileprivate struct EditNotificationsButton: View {
    @ObservedObject var viewModel: NotificationsViewModel
    
    var icon: String {
        if viewModel.isEditing {
            return !viewModel.selectedNotificationIds.isEmpty ? "trash.fill" : ""
        } else {
            return "square.and.pencil"
        }
    }
    
    var body: some View {
        Button {
            if !viewModel.selectedNotificationIds.isEmpty {
                viewModel.deleteNotifications()
            } else {
                if !viewModel.selectedNotificationIds.isEmpty {
                    viewModel.selectedNotificationIds = []
                }
                
                viewModel.isEditing.toggle()
            }
        } label: {
            if icon != "" {
                Image(systemName: icon)
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(!viewModel.selectedNotificationIds.isEmpty ? .pink : .white)
                    .padding(10)
                    .contentShape(Rectangle())
            }
        }
    }
}
