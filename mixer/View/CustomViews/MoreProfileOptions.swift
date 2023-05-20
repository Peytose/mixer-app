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
    let user: CachedUser
    @StateObject private var imageLoader: ImageLoader
    @State var showBlockAlert = false
    
    init(action: @escaping () -> Void, user: CachedUser) {
        self.action = action
        self.user = user
        _imageLoader = StateObject(wrappedValue: ImageLoader(url: user.profileImageUrl))
    }
    
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
                        .subheading2()
                    
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
                
                //MARK: Current issue: share button hard to click
                if let userId = user.id, let url = URL(string: "https://mixer.page.link/profile?uid=\(userId)") {
                    ShareLink(item: url,
                              message: Text("\nCheck out this profile on mixer!"),
                              preview: SharePreview("\(user.displayName) (@\(user.username))",
                                                    image: imageLoader.image ?? Image("default-avatar"))) {
                        HStack(spacing: 10)  {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3.weight(.medium))
                            
                            Text("Share profile")
                                .fontWeight(.medium)
                        }
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding(.horizontal, 20)
            .padding(.bottom, 180)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: buttonAction, label: {
                Image(systemName: "xmark")
            })
            .buttonStyle(SmallButtonStyle())
        }
        .alert("Block \(user.name)?", isPresented: $showBlockAlert, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Block", role: .destructive, action: {action()})
        }, message: {
            Text("\(user.name) will no longer be able to see your profile, activity, or follow you.")
        })
    }
    
    func buttonAction() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            action()
        }
    }
}

struct MoreProfileOptions_Previews: PreviewProvider {
    static var previews: some View {
        MoreProfileOptions(action: {}, user: CachedUser(from: Mockdata.user))
            .preferredColorScheme(.dark)
    }
}

