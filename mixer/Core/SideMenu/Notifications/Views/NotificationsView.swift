//
//  NotificationsView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var viewModel: NotificationsViewModel
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            List {
                ForEach(viewModel.notifications) { notification in
                    NotificationCell(cellViewModel: NotificationCellViewModel(notification: notification),
                                     path: $path)
                    .navigationDestination(for: NotificationType.self) { type in
                        switch type {
                        case .friendAccepted,
                                .friendRequest,
                                .newFollower,
                                .memberJoined,
                                .guestlistJoined:
                            if let user = notification.user {
                                ProfileView(user: user,
                                            path: $path)
                            }
                        case .memberInvited,
                                .guestlistAdded:
                            if let host = notification.host {
                                HostDetailView(host: host,
                                               path: $path)
                            }
                        case .eventLiked:
                            if let event = notification.event {
                                EventDetailView(event: event,
                                                path: $path)
                            }
                        }
                    }
                    .listRowBackground(Color.theme.secondaryBackgroundColor)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .listRowSeparator(.hidden)
        }
        .navigationBar(title: "Notifications", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBackArrowButton(path: $path)
            }
        }
    }
}
