//
//  NotificationFeedView.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI

struct NotificationFeedView: View {
    @Binding var notifications: [Notification]
    
    var body: some View {
        List {
            ForEach($notifications) { notification in
                NotificationCell(notification: notification)
                    .padding(.vertical, 5)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            NotificationsViewModel.deleteNotification(notification.wrappedValue) {
                                notifications.removeAll(where: { $0.id == notification.id })
                            }
                        } label: {
                            Label("", systemImage: "trash.fill")
                        }
                    }
            }
            .listRowBackground(Color.mixerSecondaryBackground)
        }
        .scrollContentBackground(.hidden)
        .background(Color.mixerBackground.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

struct NotificationFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationFeedView(notifications: .constant([]))
            .preferredColorScheme(.dark)
    }
}
