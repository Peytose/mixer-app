//
//  MoreProfileOptions.swift
//  mixer
//
//  Created by Jose Martinez on 4/13/23.
//

import SwiftUI
import Kingfisher

struct MoreProfileOptions: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var profileImage: Image? = nil
    
    var body: some View {
        ZStack {
            Color.theme.secondaryBackgroundColor
                .opacity(0.6)
                .backgroundBlur(radius: 5, opaque: true)
                .ignoresSafeArea()
                .onTapGesture { viewModel.isShowingMoreProfileOptions = false }
            
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 100)
                VStack(spacing: 20) {
                    KFImage(URL(string: viewModel.user.profileImageUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: DeviceTypes.ScreenSize.width * 0.50,
                               height: DeviceTypes.ScreenSize.width * 0.50)
                        .onAppear {
                            viewModel.user.profileImageUrl.loadImage { loadedImage in
                                profileImage = loadedImage
                            }
                        }
                    
                    VStack {
                        Text(viewModel.user.displayName)
                            .secondarySubheading()
                        
                        Text("@\(viewModel.user.username)")
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    if !viewModel.user.isCurrentUser {
                        Button {
                            if viewModel.user.relationshipState == .blocked {
                                viewModel.cancelRelationshipRequest()
                            } else {
                                viewModel.blockUser()
                            }
                        } label: {
                            MoreOptionRow(icon: "hand.raised",
                                          text: (viewModel.user.relationshipState == .blocked ? "Unblock " : "Block ") + viewModel.user.displayName)
                        }
                    }
                    
                    if let userId = viewModel.user.id, let url = URL(string: "https://mixer.page.link/profile?uid=\(userId)") {
                        ShareLink(item: url,
                                  message: Text("\nCheck out this profile on mixer!"),
                                  preview: SharePreview("\(viewModel.user.displayName) (@\(viewModel.user.username))", image: profileImage ?? Image("default-avatar"))) {
                            MoreOptionRow(icon: "square.and.arrow.up",
                                          text: "Share \(viewModel.user.displayName)'s profile")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .padding(.bottom, 180)
        }
    }
}

struct MoreProfileOptions_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
//            Color.red
//                .ignoresSafeArea()
            
            MoreProfileOptions(viewModel: ProfileViewModel(user: dev.mockUser))
        }
    }
}

fileprivate struct MoreOptionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.white)
            
            Text(text)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .contentShape(Rectangle())
        .padding()
    }
}
