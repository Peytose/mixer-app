//
//  AddedToGuestlistNotification.swift
//  mixer
//
//  Created by Jose Martinez on 5/3/23.
//

import SwiftUI

struct AddedToGuestlistNotification: View {
    let title: String
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                
                VStack(alignment: .leading) {
                    Text("You have been added to the guest list for")
                    
                    Text(title)
                        .fontWeight(.semibold)
                }
                .lineLimit(1)
            }
            .notificationContentFrame()
        }
        .notificationBackground()
    }
}

struct AddedToGuestlistNotification_Previews: PreviewProvider {
    static var previews: some View {
        AddedToGuestlistNotification(title: "Neon Party")
    }
}