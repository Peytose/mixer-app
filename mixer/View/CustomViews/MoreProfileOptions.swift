//
//  MoreProfileOptions.swift
//  mixer
//
//  Created by Jose Martinez on 4/13/23.
//

import SwiftUI
import Kingfisher

struct MoreProfileOptions: View {
    let action: () -> Void
    var link: String = "https://mixer.llc"
    let user: CachedUser
    @State var showBlockAlert = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 20) {
                KFImage(URL(string: user.profileImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: DeviceTypes.ScreenSize.width * 0.60, height: DeviceTypes.ScreenSize.width * 0.60)
                
                VStack {
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.mainFont)
                    
                    Text("@\(user.username)")
                        .foregroundColor(.secondary)
                }
                
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .center)
            .offset(y: -80)
            
            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 10) {
                    Image(systemName: "hand.raised")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Block user")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showBlockAlert.toggle()
                }
                
                ShareLink(item: URL(string: link)!) {
                    HStack(spacing: 10)  {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3.weight(.medium))
                        
                        Text("Share profile")
                            .fontWeight(.medium)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding(.horizontal, 20)
            .padding(.bottom, 180)
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: "xmark")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(20)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        action()
                    }
                }
        }
        .alert("Block \(user.name)?", isPresented: $showBlockAlert, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Block", role: .destructive, action: {action()})
        }, message: {
            Text("\(user.name) will no longer be able to see your profile, activity, or follow you. ")
        })
    }
}

struct MoreProfileOptions_Previews: PreviewProvider {
    static var previews: some View {
        MoreProfileOptions(action: {}, link: "https://mixer.llc", user: CachedUser(from: Mockdata.user))
            .preferredColorScheme(.dark)
    }
}

