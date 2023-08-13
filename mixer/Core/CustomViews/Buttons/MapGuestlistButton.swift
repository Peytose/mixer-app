//
//  MapGuestlistButton.swift
//  mixer
//
//  Created by Peyton Lyons on 8/10/23.
//

import SwiftUI

struct MapGuestlistButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.playLightImpact()
            action()
        } label: {
            Capsule()
                .fill(Color.theme.secondaryBackgroundColor)
                .longButtonFrame()
                .shadow(radius: 20, x: -8, y: -8)
                .shadow(radius: 20, x: 8, y: 8)
                .overlay {
                    HStack {
                        Image(systemName: "list.clipboard")
                            .imageScale(.large)
                            .foregroundColor(.white)
                        
                        Text("Guestlist")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .shadow(radius: 5, y: 10)
        }
    }
}

struct MapGuestlistButton_Previews: PreviewProvider {
    static var previews: some View {
        MapGuestlistButton() {}
    }
}
