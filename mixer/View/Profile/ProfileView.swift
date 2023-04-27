////
////  ProfileView.swift
////  mixer
////
////  Created by Peyton Lyons on 11/12/22.
////
//
//import SwiftUI
//
//struct ProfileView: View {
//    @ObservedObject var viewModel: ProfileViewModel
//    @State var showEditProfile   = false
//    @State var showNotifications = false
//    @State var showQRCode        = false
//    @State var showUsername      = false
//    @State private var selectedOption: String = "Single"
//
//    @Namespace var namespace
//
//    init(user: CachedUser) {
//        self.viewModel = ProfileViewModel(user: user)
//    }
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            StretchablePhotoBanner(imageUrl: viewModel.user.profileImageUrl,
//                                   namespace: namespace)
//                .overlay(alignment: .topTrailing) {
//                    if viewModel.user.isCurrentUser {
//                        HStack(spacing: 5) {
//                            ProfileCornerButton(action: { showNotifications.toggle() }, icon: "bell")
//                                .overlay(alignment: .topTrailing) {
//                                    SmallCornerNumber(number: "9")
//                                }
//
//                            ProfileCornerButton(action: { showEditProfile.toggle() },
//                                                icon: "gearshape")
//                            .padding(.trailing)
//                        }
//                        .padding(.top, 40)
//                    }
//                }
//                .padding(.top, -40)
//
//            profileInfo
//
//            details
//
//            VStack {
//                if viewModel.user.relationshiptoUser != .friends && !viewModel.user.isCurrentUser {
//                    Text("🫣 Sorry, you have to be friends with @\(viewModel.user.username) in order to see this info.")
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.secondary)
//                        .frame(width: UIScreen.main.bounds.width / 1.3, height: 300, alignment: .center)
//                } else {
//                    // Segmented Event Header
//                    LazyVStack(pinnedViews: [.sectionHeaders]) {
//                        Section {
//                            if viewModel.eventSection == .interests {
//                                ScrollView(.vertical, showsIndicators: false) {
//                                    if !viewModel.savedEvents.isEmpty {
//                                        ForEach(viewModel.savedEvents) { event in
//                                            NavigationLink {
//                                                EventDetailView(viewModel: EventDetailViewModel(event: event),
//                                                                namespace: namespace)
//                                            } label: {
//                                                EventCellView(event: event, hasStarted: false, namespace: namespace)
//                                                    .padding(.horizontal)
//
//                                                Divider()
//                                            }
//                                            .frame(height: 380)
//                                            .onChange(of: event.didSave) { _ in
//                                                viewModel.savedEvents.removeAll(where: { $0.id == event.id })
//                                            }
//                                        }
//                                    } else {
//                                        Text("Nothin' to see here. 🙅‍♂️")
//                                            .multilineTextAlignment(.center)
//                                            .foregroundColor(.secondary)
//                                            .frame(width: UIScreen.main.bounds.width / 1.3, height: 300, alignment: .center)
//                                    }
//                                }
//                            } else {
////                                EventListView(events: viewModel.pastEvents,
////                                              hasStarted: true,
////                                              namespace: namespace)
//                            }
//                        } header: { viewModel.stickyHeader() }
//                    }
//                }
//            }
//            .padding(.bottom, 120)
//        }
//        .task {
//            if let uid = viewModel.user.id { viewModel.getProfileEvents(uid: uid) }
//        }
//
//    }
//
//    var profileInfo: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack(alignment: .center) {
//                VStack(alignment: .leading, spacing: 2) {
//                    HStack {
//                        HStack(alignment: .bottom, spacing: 15) {
//                            Text(showUsername ? "@\(viewModel.user.username)" : viewModel.user.name)
//                                .textSelection(.enabled)
//                                .font(.largeTitle)
//                                .bold()
//                                .lineLimit(1)
//                                .minimumScaleFactor(0.5)
//                                .onTapGesture {
//                                    withAnimation(.easeInOut) {
//                                        showUsername.toggle()
//                                    }
//                                }
//
//                            Text("21")
//                                .font(.title.weight(.light))
//                        }
//
//                        Spacer()
//
//                        Button(action: { showQRCode.toggle() }) {
//                            Image(systemName: "square.and.arrow.up")
//                                .resizable()
//                                .scaledToFit()
//                                .foregroundColor(Color.mainFont)
//                                .frame(width: 25, height: 25)
//                        }
//
//                        Image("Instagram_Glyph_Gradient 1")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                    }
//
//                    HStack {
//                        Image(systemName: "graduationcap.fill")
//                            .resizable()
//                            .scaledToFill()
//                            .foregroundColor(.white)
//                            .frame(width: 15, height: 15)
//
//                        Text(viewModel.user.university)
//                            .foregroundColor(.secondary)
//                            .font(.body)
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.75)
//                    }
//
//                    HStack {
//                        Image(systemName: "house.fill")
//                            .resizable()
//                            .scaledToFill()
//                            .foregroundColor(.white)
//                            .frame(width: 15, height: 15)
//
//                        Text("MIT Theta Chi")
//                            .foregroundColor(.secondary)
//                            .font(.body)
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.75)
//                    }
//                }
//
//                Spacer()
//
//            }
//
//            if let bio = viewModel.user.bio {
//                Text(bio)
//                    .foregroundColor(.white.opacity(0.9))
//                    .font(.body.weight(.medium))
//                    .lineLimit(3)
//                    .minimumScaleFactor(0.75)
//            }
//        }
//        .padding(.horizontal)
//    }
//
//    var details: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("About")
//                .font(.title).bold()
//
//            VStack(alignment: .leading) {
//                HStack {
//                    DetailRow(image: "figure.2.arms.open", text: selectedOption)
//
//                    Spacer()
//
//                    Menu("Change") {
//                        Button("Single", action: { selectedOption = "Single" })
//                        Button("Taken", action: { selectedOption = "Taken" })
//                        Button("Complicated", action: { selectedOption = "Complicated" })
//                        Button("N/A", action: { selectedOption = "N/A" })
//                    }
//                    .accentColor(.mixerIndigo)
//                }
//
//                DetailRow(image: "briefcase", text: "Civil Engineering Major")
//
//            }
//            .fontWeight(.medium)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal)
//        .padding(.top, 16)
//
//    }
//}
//
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(viewModel: ProfileViewModel(user: CachedUser(from: Mockdata.user)))
//            .preferredColorScheme(.dark)
//    }
//}
//
//fileprivate struct ProfileCornerButton: View {
//    let action: () -> Void
//    let icon: String
//
//    var body: some View {
//        Button {
//            let impact = UIImpactFeedbackGenerator(style: .light)
//            impact.impactOccurred()
//            withAnimation(.spring()) { action() }
//        } label: {
//            Image(systemName: icon)
//                .resizable()
//                .scaledToFit()
//                .foregroundColor(Color.mainFont)
//                .frame(width: 25, height: 25)
//                .padding(.vertical)
//                .padding(.horizontal, 5)
//        }
//    }
//}
//
//

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

    @Namespace var animation
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ProfileViewModel
    
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
                        HStack(spacing: viewModel.user.isCurrentUser ? 5 : 5) {
                            if viewModel.user.isCurrentUser {
                                ProfileCornerButton(isOn: $showNotifications, icon: "bell")
                                    .overlay(alignment: .topTrailing) {
                                        IconBadge(count: viewModel.notifications.count)
                                    }
                                
                                ProfileCornerButton(isOn: $showEditProfile,
                                                    icon: "gearshape")
                                .padding(.trailing)
                                
                            } else {
                                //MARK: Friend button (debug report: looks jank as fuck and i dont believe it works)
//                                if let relationship = viewModel.user.relationshiptoUser {
//                                    HStack(alignment: .center, spacing: 5) {
//                                        ProfileRelationButton(icon: relationship.buttonSystemImage, color: .primary) {
//                                            switch relationship {
//                                            case .friends, .sentRequest:
//                                                viewModel.cancelFriendRequest()
//                                            case .receivedRequest:
//                                                viewModel.acceptFriendRequest()
//                                            case .notFriends:
//                                                viewModel.sendFriendRequest()
//                                            }
//                                        }
//
//                                        if relationship == .receivedRequest {
//                                            ProfileRelationButton(icon: "xmark", color: .red) {
//                                                viewModel.cancelFriendRequest()
//                                            }
//                                        }
//                                    }
//                                }
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    BackArrowButton()
                                })
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                Image(systemName: "ellipsis")
                                    .font(.callout)
                                    .padding(12)
                                    .background {
                                        Circle()
                                            .stroke(lineWidth: 1.3)
                                            .foregroundColor(.white)
                                    }
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                            showOptions.toggle()
                                        }
                                    }
                                    .padding(.horizontal)
                                
                                
                                
                            }
                        }
                        .padding(.top, 40)
                    }
                
                ProfileInfo(user: $viewModel.user, mutuals: viewModel.mutuals)
                
                details
                
                //MARK: Profile event list (debug report: 
//                EventsSection(viewModel: viewModel,
//                              showEventView: $showEventView,
//                              isFriends: $isFriends,
//                              namespace: namespace,
//                              selectedEvent: $selectedEvent)
            }
            .background(Color.mixerBackground)
            .coordinateSpace(name: "scroll")
            .preferredColorScheme(.dark)
            .ignoresSafeArea(.all)
            .navigationBarHidden(true)
            .statusBar(hidden: true)
            .sheet(isPresented: $showEditProfile) { ProfileSettingsView(viewModel: viewModel) }
            .sheet(isPresented: $showNotifications) { NotificationFeedView() }
            //            .fullScreenCover(isPresented: $viewModel.showEventView) {
            //                EventInfoView(parentViewModel: ExplorePageViewModel(), tabBarVisibility: $tabBarVisibility, event: eventManager.selectedEvent!, coordinates: CLLocationCoordinate2D(latitude: 40, longitude: 50), namespace: namespace)
            //            }
            
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
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(user: CachedUser(from: Mockdata.user)))
    }
}

fileprivate struct ProfileRelationButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10))
                .background {
                    Capsule()
                        .stroke(lineWidth: 1.3)
                }
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()

                }
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
        }
    }
}

fileprivate struct ProfileInfo: View {
    @State private var showUsername: Bool = false
    @Binding var user: CachedUser
    let mutuals: [CachedUser]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        HStack(alignment: .center, spacing: 15) {
                            Text(showUsername ? "@\(user.username)" : user.name)
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

extension ProfileView {
    
    var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.title)
                .bold()
            
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
