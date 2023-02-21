//
//  UserIconList.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI

struct UserIconList: View {
    let users: [User?]
    
    var body: some View {
        HStack(spacing: -8) {
            Circle()
                .stroke()
                .foregroundColor(.mixerSecondaryBackground)
                .frame(width: 28, height: 46)
                .overlay {
                    Image("profile-banner-1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            
            Circle()
                .stroke()
                .foregroundColor(.mixerSecondaryBackground)
                .frame(width: 28, height: 46)
                .overlay {
                    Image("profile-banner-1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            
            Circle()
                .fill(Color.mixerSecondaryBackground)
                .frame(width: 28, height: 46)
                .overlay {
                    Text("+3")
                        .foregroundColor(.white)
                        .font(.footnote)
                }
            
            Text("going")
                .font(.body.weight(.semibold))
                .foregroundColor(.primary.opacity(0.7))
                .padding(.leading, 13)
        }
    }
}

struct UserIconList_Previews: PreviewProvider {
    static var previews: some View {
        UserIconList(users: [])
    }
}
