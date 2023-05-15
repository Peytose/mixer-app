//
//  FriendRequestSentNotification.swift
//  mixer
//
//  Created by Jose Martinez on 5/3/23.
//

import SwiftUI

struct FriendRequestSentNotification: View {
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "person.2.fill")
                
                VStack(alignment: .leading) {
                    Text("Friend request sent")
                }
                .font(.subheadline)
                .lineLimit(1)
            }
            .notificationContentFrameShort()
        }
        .notificationBackgroundShort()
    }
}

struct FriendRequestSentNotification_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestSentNotification()
            .preferredColorScheme(.dark)
    }
}
