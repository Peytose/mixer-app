//
//  NotificationFeedView.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI

struct NotificationFeedView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(0..<6) { cell in
                        FollowRequestCell()
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
        NotificationFeedView()
            .preferredColorScheme(.dark)
    }
}
