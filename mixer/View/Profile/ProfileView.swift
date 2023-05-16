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
    @Environment(\.presentationMode) var presentationMode
    @State var showOptions = false
    @State private var selection = "None"
    @State var showAlert = false
    @Binding var isFriends: Bool
    @State var showUsername = false
    @State var showEventView = false
    @State var showEditProfile = false
    @State var showNotifications = false
    @State var selectedEvent: CachedEvent?
    @State var showChangeMajor   = false
    @State var friendRequestSent = false
    
    @Namespace var animation
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var notificationsViewModel = NotificationsViewModel()
    
    init(viewModel: ProfileViewModel) {
        self._isFriends = Binding(get: { viewModel.user.relationshiptoUser == .friends },
                                  set: { _ in })
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                StretchablePhotoBanner(imageUrl: viewModel.user.profileImageUrl, namespace: namespace)
                    .overlay(alignment: .topTrailing) {
                        HStack(spacing: viewModel.user.isCurrentUser ? 5 : 10) {
                            if viewModel.user.isCurrentUser {
                                ProfileCornerButton(isOn: $showNotifications, icon: "bell")
                                    .overlay(alignment: .topTrailing) {
                                        IconBadge(count: notificationsViewModel.notifications.filter({ !$0.hasBeenSeen }).count)
                                            .offset(x: -2, y: -2)
                                    }
                                
                                ProfileCornerButton(isOn: $showEditProfile,
                                                    icon: "gearshape")
                                .padding(.trailing)
                                
                            } else {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    BackArrowButton()
                                })
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                if let _ = viewModel.user.relationshiptoUser {
                                    ProfileRelationButtons(viewModel: viewModel,
                                                           friendRequestSent: $friendRequestSent)
                                }
                                
                                Image(systemName: "ellipsis")
                                    .font(.callout)
                                    .padding(11)
                                    .contentShape(Rectangle())
                                    .background {
                                        Circle()
                                            .stroke(lineWidth: 1.3)
                                            .foregroundColor(.white)
                                    }
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            showOptions.toggle()
                                            friendRequestSent.toggle()
                                        }
                                    }
                                    .padding(.trailing)
                            }
                        }
                        .padding(.top, viewModel.user.isCurrentUser ? 40 : 60)
                    }
                
                ProfileInfo(user: $viewModel.user, viewModel: viewModel, mutuals: viewModel.mutuals)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .heading()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            DetailRow(image: "figure.2.arms.open", text: viewModel.relationshipStatus.rawValue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Spacer()
                            
                            if viewModel.user.isCurrentUser {
                                Menu("Change") {
                                    ForEach(RelationshipStatus.allCases, id: \.self) { status in
                                        Button(status.rawValue) {
                                            viewModel.relationshipStatus = status
                                            viewModel.save(for: .relationship)
                                        }
                                    }
                                }
                                .accentColor(.mixerIndigo)
                            }
                        }
                        
                        HStack {
                            DetailRow(image: "briefcase", text: viewModel.major.rawValue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Spacer()
                            
                            if viewModel.user.isCurrentUser {
                                Menu("Change") {
                                    ForEach(StudentMajor.allCases, id: \.self) { major in
                                        Button(major.rawValue) {
                                            viewModel.major = major
                                            viewModel.save(for: .major)
                                        }
                                    }
                                }
                                .accentColor(.mixerIndigo)
                            }
                        }
                    }
                    .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .background(Color.mixerBackground)
            .coordinateSpace(name: "scroll")
            .preferredColorScheme(.dark)
            .ignoresSafeArea(.all)
            .navigationBarHidden(true)
            .statusBar(hidden: true)
            .sheet(isPresented: $showEditProfile) { ProfileSettingsView(viewModel: viewModel) }
            .sheet(isPresented: $showNotifications) {
                NavigationView {
                    NotificationFeedView(notifications: $notificationsViewModel.notifications)
                        .navigationTitle("Notifications")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button { showNotifications = false  } label: { XDismissButton() }
                            }
                        }
                }
            }
            
            Color.mixerSecondaryBackground.opacity(0.6)
                .backgroundBlur(radius: 5, opaque: true)
                .padding(-20)
                .blur(radius: 20)
                .ignoresSafeArea()
                .opacity(showOptions ? 1 : 0)
            
            if showOptions {
                MoreProfileOptions(action: {
                    withAnimation() {
                        showOptions.toggle()
                    }
                }, user: viewModel.user)
                .transition(.move(edge: .bottom).combined(with: .scale(scale: 1.3)))
                .zIndex(3)
            }
        }
        .popup(isPresented: $friendRequestSent) {
            FriendRequestSentNotification()
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .autohideIn(2)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(user: CachedUser(from: Mockdata.user)))
    }
}

fileprivate struct ProfileRelationButtons: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var friendRequestSent: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Button {
                switch viewModel.user.relationshiptoUser {
                case .friends, .sentRequest:
                    viewModel.cancelFriendRequest()
                    friendRequestSent = false
                case .receivedRequest:
                    viewModel.acceptFriendRequest()
                    friendRequestSent = true
                case .notFriends:
                    viewModel.sendFriendRequest()
                case .none:
                    break
                }
            } label: {
                switch viewModel.user.relationshiptoUser {
                case .friends:
                    Text("\(Image(systemName: "person.fill.checkmark"))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                        .background {
                            Capsule()
                                .stroke()
                        }
                case .notFriends:
                    Text("Add Friend")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                        .background {
                            Capsule()
                                .stroke()
                        }
                case .sentRequest:
                    Text("Requested")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                        .background {
                            Capsule()
                                .stroke()
                        }
                case .receivedRequest:
                    Text("")
                case .none:
                    Text("")
                }
            }
            .buttonStyle(.plain)
        }
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
                .foregroundColor(Color.mainFont)
                .frame(width: 25, height: 25)
                .padding(.vertical)
                .padding(.horizontal, 5)
                .contentShape(Rectangle())
        }
    }
}

fileprivate struct ProfileInfo: View {
    @State private var showUsername: Bool = false
    @Binding var user: CachedUser
    @ObservedObject var viewModel: ProfileViewModel
    let mutuals: [CachedUser]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        HStack(alignment: .center, spacing: 15) {
                            Text(showUsername ? "@\(user.username)" : user.displayName)
                                .textSelection(.enabled)
                                .font(.largeTitle)
                                .bold()
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showUsername.toggle()
                                    }
                                }
                            
                            if let age = user.age, user.userOptions[UserOption.showAgeOnProfile.rawValue] ?? false {
                                Text("\(age)")
                                    .font(.title)
                                    .fontWeight(.light)
                                
                            }
                        }
                        
                        Spacer()
                        
                        if let instagramUrl = URL(string: "https://www.instagram.com/\(user.instagramHandle ?? "mixerpartyapp")/") {
                            Link(destination: instagramUrl) {
                                Image("Instagram_Glyph_Gradient 1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                    if let university = user.universityData["name"] {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.white)
                                .frame(width: 15, height: 15)
                            
                            Text(university)
                                .foregroundColor(.secondary)
                                .font(.body)
                                .subheading3(foregroundColor: .secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    
                    if let memberHosts = user.memberHosts {
                        ForEach(memberHosts) { host in
                            HStack {
                                Image(systemName: host.hostType.icon)
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
            
            if viewModel.user.relationshiptoUser == .receivedRequest {
                HStack {
                    Text("\(Text(user.name).fontWeight(.semibold)) wants to be friends")
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                    
                    Spacer()
                    
                    ActionButton(text: "Accept", color: Color.mixerIndigo) {
                        viewModel.acceptFriendRequest()
                    }
                    
                    ActionButton(text: "Reject", color: Color.mixerSecondaryBackground) {
                        viewModel.cancelFriendRequest()
                    }
                }
                .frame(maxHeight: 60)
            }
            
            if let bio = user.bio {
                Text(bio)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
            }
            
            if mutuals.count > 0 { UserIconList(users: mutuals) }
        }
        .padding(.horizontal)
    }
}

fileprivate struct EventsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showEventView: Bool
    @Binding var isFriends: Bool
    var namespace: Namespace.ID
    @Binding var selectedEvent: CachedEvent?
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section(header: viewModel.stickyHeader()) {
                        if isFriends {
                            EventListView(events: viewModel.eventSection == .interests ? viewModel.savedEvents : viewModel.pastEvents,
                                          hasStarted: true,
                                          namespace: namespace,
                                          selectedEvent: $selectedEvent,
                                          showEventView: $showEventView) { event, hasStarted, namespace in
                                EventCellView(event: event, hasStarted: hasStarted, namespace: namespace)
                            }
                        } else {
//                            Text("Only \(isFriends ? "@" + viewModel.user.username : "friends") can see this activity")
//                                .font(.title)
//                                .bold()
//                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 120)
    }
}

private struct PaddedImage: View {
    var image: String
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .padding(8)
                .background(.ultraThinMaterial)
                .backgroundStyle(cornerRadius: 10, opacity: 0.5)
                .cornerRadius(10)
        }
    }
}
