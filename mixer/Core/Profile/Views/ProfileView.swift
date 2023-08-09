//
//  ProfileView.swift
//  mixer
//
//  Created by Jose Martinez on 12/20/22.
//

import SwiftUI
import MapKit
import Kingfisher
import TabBar
import PopupView

struct ProfileView: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    @State private var showOptions  = false
    @State private var showUsername = false
    
    @Namespace var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                // Banner and overlayed button(s)
                banner
                
                // Name, age, links, school and bio
                profileInfo
                
                // Contains user relationship status and major
                aboutSection
            }
            .background(Color.theme.backgroundColor)
            .preferredColorScheme(.dark)
            .ignoresSafeArea(.all)
            .navigationBarHidden(true)
            .statusBar(hidden: true)
            
            if showOptions {
                Color.theme.secondaryBackgroundColor.opacity(0.6)
                    .backgroundBlur(radius: 5, opaque: true)
                    .padding(-20)
                    .blur(radius: 20)
                    .ignoresSafeArea()
                
                MoreProfileOptions()
                    .transition(.move(edge: .bottom).combined(with: .scale(scale: 1.3)))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackArrowButton()
            }
        }
    }
}

extension ProfileView {
    var banner: some View {
        StretchablePhotoBanner(imageUrl: viewModel.user.profileImageUrl, namespace: namespace)
            .overlay(alignment: .topTrailing) {
                if !viewModel.user.isCurrentUser {
                    Image(systemName: "ellipsis")
                        .font(.callout)
                        .padding(10)
                        .contentShape(Rectangle())
                        .background {
                            Circle()
                                .stroke(lineWidth: 1.3)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            HapticManager.playLightImpact()
                            showOptions.toggle()
                        }
                        .padding(.trailing)
                        .padding(.top, 60)
                }
            }
    }
    
    var profileInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        HStack(alignment: .center, spacing: 15) {
                            Text(showUsername ? "@\(viewModel.user.username)" : viewModel.user.displayName)
                                .largeTitle()
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .textSelection(.enabled)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showUsername.toggle()
                                    }
                                }
                            
                            if let age = viewModel.user.age, viewModel.user.showAgeOnProfile {
                                Text("\(age)")
                                    .font(.title)
                                    .fontWeight(.light)
                            }
                        }
                        
                        Spacer()
                        
                        if let instagramUrl = URL(string: "https://www.instagram.com/\(viewModel.user.instagramHandle ?? "mixerpartyapp")/") {
                            Link(destination: instagramUrl) {
                                Image("Instagram_Glyph_Gradient 1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.white)
                            .frame(width: 15, height: 15)
                        
                        Text(viewModel.user.university)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    
                    if let memberHosts = viewModel.user.associatedHosts {
                        ForEach(memberHosts) { host in
                            HStack {
                                KFImage(URL(string: host.hostImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.white)
                                    .frame(width: 15, height: 15)
                                
                                Text(host.name)
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            FriendshipButtonsView()
            
            if let bio = viewModel.user.bio {
                Text(bio)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
            }
            
            if viewModel.user.friendshipState != .friends, viewModel.mutuals.count > 0 {
                UserIconList(users: viewModel.mutuals)
            }
        }
        .padding(.horizontal)
    }
    
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .primaryHeading()
            
            VStack(alignment: .leading) {
                HStack {
                    if let status = viewModel.user.relationshipStatus {
                        DetailRow(image: status.icon, text: status.stringVal)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    if let major = viewModel.user.major {
                        DetailRow(image: major.icon, text: major.stringVal)
                    }
                    
                    Spacer()
                }
            }
            .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ProfileViewModel(user: dev.mockUser))
    }
}

fileprivate struct ProfileCornerButton: View {
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring()) { isOn.toggle() }
        } label: {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .padding(.vertical)
                .padding(.horizontal, 5)
                .contentShape(Rectangle())
        }
    }
}
