//
//  ProfileView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State var showEditProfile = false
    @State var showQRCode      = false
    @State var showUsername    = false
    @Namespace var namespace
    
    init(user: User) {
        self.viewModel = ProfileViewModel(user: user)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            StretchablePhotoBanner(imageUrl: viewModel.user.profileImageUrl)
                .overlay(alignment: .topTrailing) {
                    if viewModel.user.isCurrentUser {
                        ProfileCornerButton(action: { showEditProfile.toggle() },
                                            icon: "gearshape")
                        .onTapGesture { showEditProfile.toggle() }
                        .padding(.trailing)
                        .padding(.top, 40)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if viewModel.user.isCurrentUser {
                        ProfileCornerButton(action: { showQRCode.toggle() },
                                            icon: "qrcode")
                        .onTapGesture { showQRCode.toggle() }
                        .padding(.leading)
                        .padding(.top, 40)
                    }
                }
                .padding(.top, -40)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(showUsername ? "@\(viewModel.user.username)" : "\(viewModel.user.name)")
                                .textSelection(.enabled)
                                .font(.title)
                                .bold()
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showUsername.toggle()
                                    }
                                }
                            
//                            Text("\(viewModel.user.age)")
//                                .foregroundColor(.secondary)
//                                .font(.title2)
//                                .lineLimit(1)
                        }
                        
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.white)
                                .frame(width: 15, height: 15)
                            
                            Text(viewModel.user.university)
                                .foregroundColor(.secondary)
                                .font(.body)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    
                    Spacer()
                    
                    if let relationship = viewModel.user.relationshiptoUser {
                        ProfileRelationButton(action: {
                            switch relationship {
                            case .notFriends:
                                viewModel.sendFriendRequest()
                            case .receivedRequest:
                                viewModel.acceptFriendRequest()
                            default:
                                viewModel.cancelFriendRequest()
                            }
                        }, icon: relationship.buttonSystemImage, color: .blue)
                        .overlay(alignment: .center) {
                            if relationship == UserRelationship.receivedRequest {
                                ProfileRelationButton(action: viewModel.cancelFriendRequest, icon: "person.fill.xmark", color: .pink)
                                    .padding(.bottom, 100)
                            }
                        }
                    }
                }
                
                if let bio = viewModel.user.bio {
                    Text(bio)
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .lineLimit(3)
                        .minimumScaleFactor(0.75)
                }
            }
            .padding(.horizontal)
            
            VStack {
                if viewModel.user.relationshiptoUser != .friends && !viewModel.user.isCurrentUser {
                    Text("🫣 Sorry, you have to be friends with @\(viewModel.user.username) in order to see this info.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .frame(width: UIScreen.main.bounds.width / 1.3, height: 300, alignment: .center)
                } else {
                    // Segmented Event Header
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section {
                            if viewModel.eventSection == .interests {
                                ScrollView(.vertical, showsIndicators: false) {
                                    if !viewModel.savedEvents.isEmpty {
                                        ForEach(viewModel.savedEvents) { event in
                                            NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event))) {
                                                EventCellView(event: event, hasStarted: false)
                                                    .padding(.horizontal)
                                                
                                                Divider()
                                            }
                                            .frame(height: 380)
                                            .onChange(of: event.didSave) { _ in
                                                viewModel.savedEvents.removeAll(where: { $0.id == event.id })
                                            }
                                        }
                                    } else {
                                        Text("Nothin' to see here. 🙅‍♂️")
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.secondary)
                                            .frame(width: UIScreen.main.bounds.width / 1.3, height: 300, alignment: .center)
                                    }
                                }
                            } else {
                                EventListView(events: viewModel.pastEvents, hasStarted: true)
                            }
                        } header: { viewModel.stickyHeader() }
                    }
                }
            }
            .padding(.bottom, 120)
        }
        .task {
            if let uid = viewModel.user.id { viewModel.getProfileEvents(uid: uid) }
        }
        .sheet(isPresented: $showEditProfile) { ProfileSettingsView(user: $viewModel.user) }
        .fullScreenCover(isPresented: $showQRCode) {  }
        .padding(.top, 40)
        .background(Color.mixerBackground)
        .coordinateSpace(name: "scroll")
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.all)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(user: Mockdata.user)
                .preferredColorScheme(.dark)
                .statusBar(hidden: false)
        }
    }
}

fileprivate struct ProfileCornerButton: View {
    let action: () -> Void
    let icon: String
    
    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring()) { action() }
        } label: {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.mainFont)
                .frame(width: 25, height: 25)
                .padding()
        }
    }
}


fileprivate struct ProfileRelationButton: View {
    let action: () -> Void
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color)
                    .frame(width: 45, height: 45)
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
            }
        }
    }
}
