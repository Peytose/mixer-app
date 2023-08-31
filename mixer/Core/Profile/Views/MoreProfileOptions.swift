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
    @Environment(\.presentationMode) var mode
    @State private var profileImage: Image? = nil
    @State var showBlockAlert               = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 20) {
                KFImage(URL(string: viewModel.user.profileImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: DeviceTypes.ScreenSize.width * 0.60,
                           height: DeviceTypes.ScreenSize.width * 0.60)
                    .onAppear {
                        viewModel.user.profileImageUrl.loadImage { loadedImage in
                            profileImage = loadedImage
                        }
                    }
                
                VStack {
                    Text(viewModel.user.name)
                        .secondarySubheading()
                    
                    Text("@\(viewModel.user.username)")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .center)
            .offset(y: -80)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "hand.raised")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Block viewModel.user")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .contentShape(Rectangle())
                .padding()
                .onTapGesture {
                    showBlockAlert.toggle()
                }
                
                if let userId = viewModel.user.id, let url = URL(string: "https://mixer.page.link/profile?uid=\(userId)") {
                    ShareLink(item: url,
                              message: Text("\nCheck out this profile on mixer!"),
                              preview: SharePreview("\(viewModel.user.displayName) (@\(viewModel.user.username))", image: profileImage ?? Image("default-avatar"))) {
                        HStack(spacing: 10)  {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3.weight(.medium))
                            
                            Text("Share profile")
                                .fontWeight(.medium)
                        }
                        .contentShape(Rectangle())
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding(.bottom, 180)
        }
        .overlay(alignment: .topTrailing) {
            XDismissButton { mode.wrappedValue.dismiss() }
                .buttonStyle(SmallButtonStyle())
        }
        .alert("Block \(viewModel.user.name)?", isPresented: $showBlockAlert, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Block", role: .destructive, action: {})
        }, message: {
            Text("\(viewModel.user.name) will no longer be able to see your profile, activity, or follow you.")
        })
    }
}

struct MoreProfileOptions_Previews: PreviewProvider {
    static var previews: some View {
        MoreProfileOptions(viewModel: ProfileViewModel(user: dev.mockUser))
    }
}

