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
    @State private var showUsername = false
    var action: ((NavigationState, Event?, Host?, User?) -> Void)?
    
    init(user: User, action: ((NavigationState, Event?, Host?, User?) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
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
                .overlay(alignment: .topTrailing) {
                    if action != nil {
                        EllipsisButton {
                            viewModel.isShowingMoreProfileOptions.toggle()
                            HapticManager.playLightImpact()
                        }
                        .background {
                            Circle()
                                .stroke(lineWidth: 1.3)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                    }
                }
                
                // Name, age, links, school and bio
                profileInfo
                
                // Contains user relationship status and major
                if (viewModel.user.relationshipState == .friends || viewModel.user.isCurrentUser)
                    && (viewModel.user.datingStatus != nil || viewModel.user.major != nil) {
                    aboutSection
                }
            }
            .ignoresSafeArea(.all)
            .statusBar(hidden: true)
            
            if viewModel.isShowingMoreProfileOptions {
                MoreProfileOptions(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .scale(scale: 1.3)))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if action == nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    PresentationBackArrowButton()
                }
            }
            
            if action == nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isShowingMoreProfileOptions.toggle()
                        HapticManager.playLightImpact()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.callout)
                            .foregroundColor(.white)
                            .padding(10)
                            .contentShape(Rectangle())
                            .background {
                                Circle()
                                    .stroke(lineWidth: 1.3)
                                    .foregroundColor(.white)
                            }
                    }
                }
            }
        }
        .alert(item: $viewModel.currentAlert) { alertType in
            hideKeyboard()
            
            switch alertType {
            case .regular(let alertItem):
                guard let item = alertItem else { break }
                return item.alert
            case .confirmation(let confirmationAlertItem):
                guard let item = confirmationAlertItem else { break }
                return item.alert
            }
            
            return Alert(title: Text("Unexpected Error"))
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
                            
                            if let age = viewModel.user.age, viewModel.user.showAgeOnProfile {
                                Text("\(age)")
                                    .font(.title)
                                    .fontWeight(.light)
                            }
                        }
                        
                        Spacer()
                        
                        if let instagramUrl = URL(string: "https://www.instagram.com/\(viewModel.user.instagramHandle ?? "mixerpartyapp")/") {
                            Link(destination: instagramUrl) {
                                Image("instagram")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                    if let university = viewModel.user.university, university.id != "com" {
                        DetailRow(text: university.shortName ?? university.name,
                                  icon: "building.columns.fill")
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
            
            if !viewModel.user.isCurrentUser {
                RelationshipButtonsView(viewModel: viewModel)
            }
            
            if let bio = viewModel.user.bio {
                Text(bio)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
            }
            
            if viewModel.user.relationshipState != .friends, viewModel.mutuals.count > 0 {
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
    }
}
