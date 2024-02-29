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
    @StateObject var viewModel: ProfileViewModel
    @StateObject var friendsViewModel: FriendsViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State private var showUsername = false
    
    var action: ((NavigationState, Event?, Host?, User?) -> Void)?
    
    init(user: User, action: ((NavigationState, Event?, Host?, User?) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
        self._friendsViewModel = StateObject(wrappedValue: FriendsViewModel())
        self.action     = action
    }
    
    @Namespace var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                // Banner and overlayed button(s)
                StretchablePhotoBanner(imageUrl: viewModel.user.profileImageUrl,
                                       namespace: namespace)
                
                if viewModel.user.relationshipState != .friends, viewModel.mutuals.count > 0 {
                    UserIconList(users: viewModel.mutuals)
                }
                
                // Name, age, links, school and bio
                profileInfo
                
                // Contains user relationship status and major
                if (viewModel.user.relationshipState == .friends || viewModel.user.isCurrentUser)
                    && (viewModel.user.datingStatus != nil || viewModel.user.major != nil) {
                    aboutSection
                        .padding(.bottom, 180)
                }
            }
            .ignoresSafeArea(.all)
            .statusBar(hidden: true)
            
            if viewModel.isShowingMoreProfileOptions,
               !viewModel.user.isCurrentUser {
                MoreProfileOptions(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .scale(scale: 1.3)))
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            HStack {
                if !viewModel.user.isCurrentUser && action == nil {
                    PresentationBackArrowButton()
                }
                
                Spacer()
                
                if viewModel.user.isCurrentUser {
                    NavigationLink {
                        NotificationsView()
                            .environmentObject(homeViewModel)
                    } label: {
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.trailing)
                            .shadow(color: .black, radius: 3)
                    }
                    
                    NavigationLink {
                        SettingsView(viewModel: settingsViewModel)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 3)
                    }
                } else {
                    EllipsisButton {
                        viewModel.isShowingMoreProfileOptions.toggle()
                        HapticManager.playLightImpact()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .withAlerts(currentAlert: $viewModel.currentAlert)
        .onAppear {
            friendsViewModel.fetchFriends()
        }
    }
}

extension ProfileView {
    var profileInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
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
                            
                            if viewModel.user.showAgeOnProfile {
                                Text("\(viewModel.user.age)")
                                    .font(.title)
                                    .fontWeight(.light)
                            }
                        }
                        
                        Spacer()
                        
                        if viewModel.user.isCurrentUser {
                            NavigationLink {
                                if let user = settingsViewModel.user,
                                   let image = user.id?.generateQRCode() {
                                    MixerIdView(user: user,
                                                image: Image(uiImage: image))
                                }
                            } label: {
                                Image(systemName: "qrcode")
                                    .font(.title2)
                                    .foregroundColor(Color.theme.Offwhite2)
                                    .padding(.trailing, 8)
                                    .shadow(color: .black, radius: 3)
                            }
                        }
                        
                        if let handle = viewModel.user.instagramHandle {
                            if let instagramUrl = URL(string: "https://www.instagram.com/\(handle)/") {
                                Link(destination: instagramUrl) {
                                    Image("instagram")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        if let university = viewModel.user.university, university.id != "com" {
                            DetailRow(text: university.shortName ?? university.name,
                                      icon: "graduationcap.fill")
                        }
                        
                        Spacer()
                        
                        if !viewModel.user.isCurrentUser {
                            RelationshipButtonsView(viewModel: viewModel)
                        }
                    }
                    
                    if let memberHosts = viewModel.user.associatedHosts {
                        ForEach(memberHosts) { host in
                            DetailRow(text: host.name,
                                      imageUrl: host.hostImageUrl)
                        }
                    }
                }
                
                Spacer()
            }
            
            if let bio = viewModel.user.bio {
                Text(bio)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
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
                    if let status = viewModel.user.datingStatus {
                        DetailRow(text: status.description,
                                  icon: status.icon)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    if let major = viewModel.user.major {
                        DetailRow(text: major.description,
                                  icon: major.icon)
                    }
                    
                    Spacer()
                }
            }
            .fontWeight(.medium)
            if viewModel.user.isCurrentUser {
                Text("Friends")
                    .primaryHeading()
                    .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(friendsViewModel.friends.prefix(2)) { friend in
                        NavigationLink {
                            ProfileView(user: friend)
                        } label: {
                            ItemInfoCell(title: friend.firstName, subtitle: "@\(friend.username)", imageUrl: friend.profileImageUrl, university: friend.university?.shortName ?? "MIT")
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if friendsViewModel.friends.count > 2 {
                        NavigationLink(destination: FriendsView()) {
                            ShowMoreFriendsButton(numOfFriends: friendsViewModel.friends.count)
                            .padding(.top, 8)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 16)
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: dev.mockUser)
            .environmentObject(SettingsViewModel())
    }
}

fileprivate struct ShowMoreFriendsButton: View {
    let numOfFriends: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.white)
                    .frame(width: 350, height: 45)
                    .overlay {
                        Text("See all \(numOfFriends) friends")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
            }
            
            Spacer()
        }
    }
}
