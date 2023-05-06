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
        NavigationView {
            ScrollView {
                VStack {
                    ForEach($notifications) { notification in
                        NotificationCell(notification: notification)
                            .padding(.vertical, 5)
                    }
                }
                .padding()
                .navigationTitle("Notifications")
            }
            .background(Color.mixerBackground)
        }
        .preferredColorScheme(.dark)
    }
}

struct NotificationFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationFeedView(notifications: .constant([]))
            .preferredColorScheme(.dark)
    }
}
