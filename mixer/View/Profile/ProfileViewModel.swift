//
//  ProfileViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import Firebase

class ProfileViewModel: ObservableObject {
    @Published var user: CachedUser
    @Published var showSettingsView     = false
    @Published var showUnfriendAlert    = false
    @Published var continueUnfriendFunc = false
    @Published var eventSection         = EventSection.interests
    @Published var savedEvents          = [CachedEvent]()
    @Published var pastEvents           = [CachedEvent]()
    @Published var mutuals              = [CachedUser]()
    @Published var notifications        = [Notification]()
    @Published var relationshipStatus   = "Single"
    @Published var major                = "N/A"
    
    enum EventSection: String, CaseIterable {
        case interests
        case past
        
        func sectionTitle(for isSelf: Bool) -> String {
            switch self {
            case .interests: return isSelf ? "Interests" : "Shared Interests"
            case .past: return isSelf ? "History" : "Mutual History"
            }
        }
    }
    
    init(user: CachedUser) {
        self.user = user
        getUserRelationship()
        print("DEBUG: profile init ran")
    }
    
    
    @ViewBuilder func stickyHeader() -> some View {
        let isSelf = user.isCurrentUser
        
        HStack {
            ForEach(EventSection.allCases, id: \.self) { [self] section in
                VStack(spacing: 8) {
                    Text(section.sectionTitle(for: isSelf))
                        .font(.title3.weight(.semibold))
                        .foregroundColor(eventSection == section ? .white : .gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    ZStack{
                        if eventSection == section {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.mixerIndigo)
                        } else {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(.clear)
                        }
                    }
                    .padding(.horizontal,8)
                    .frame(height: 4)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.eventSection = section
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 25)
        .padding(.bottom,5)
    }
    
    
    func sendFriendRequest() {
        guard let uid = user.id else { return }
        UserService.sendFriendRequest(uid: uid) { _ in
            self.user.relationshiptoUser = .sentRequest
            NotificationsViewModel.uploadNotifications(toUid: uid, type: .follow)
        }
    }
    
    
    func acceptFriendRequest() {
        guard let uid = user.id else { return }
        UserService.acceptFriendRequest(uid: uid) { _ in
            self.user.relationshiptoUser = .friends
            NotificationsViewModel.uploadNotifications(toUid: uid, type: .follow)
        }
    }
    
    
    func cancelFriendRequest() {
        guard let uid = user.id else { return }
        if self.user.relationshiptoUser == .friends { showUnfriendAlert = true }
        
        if continueUnfriendFunc || self.user.relationshiptoUser == .receivedRequest {
            UserService.cancelRequestOrRemoveFriend(uid: uid) { _ in
                self.user.relationshiptoUser = .notFriends
            }
        }
    }
    
    
    func getUserRelationship() {
        guard !user.isCurrentUser else {
            print("DEBUG: This is the current user's profile!")
            return
        }
        
        guard let uid = user.id else { return }
        
        UserService.getUserRelationship(uid: uid) { relation in
            self.user.relationshiptoUser = relation
        }
    }
    
    
    @MainActor func getProfileEvents(uid: String) {
        if user.relationshiptoUser != .friends && uid != AuthViewModel.shared.currentUser?.id { return }
        
        Task {
            do {
                self.savedEvents = try await EventCache.shared.fetchEvents(filter: .userSaves(uid: uid))
            } catch {
                print("DEBUG: Error getting profile events. \(error.localizedDescription)")
            }
        }
    }
    
    
    //    func fetchUsersStats() {
    //        guard let uid = user.id else { return }
    //
    //        COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
    //            guard let following = snapshot?.documents.count else { return }
    //
    //            COLLECTION_FRIENDS.document(uid).collection("user-friends").getDocuments { snapshot, _ in
    //                guard let followers = snapshot?.documents.count else { return }
    //
    //                self.user.stats = UserStats(following: following, followers: followers)
    //            }
    //        }
    //    }
    
    @Published var name: String             = ""
    @Published var bio: String              = ""
    @Published var instagramHandle: String  = ""
    @Published var selectedImage: UIImage?
    var phoneNumber: String { return Auth.auth().currentUser?.phoneNumber ?? "" }
    let privacyLink = "https://mixer.llc/privacy-policy/"

    enum ProfileSaveType {
        case name
        case image
        case bio
        case instagram
        case ageToggle
    }
    
    
    func save(for type: ProfileSaveType, toggleValue: Bool = false) {
        self.save(for: type, toggleValue: toggleValue) {
            self.cacheUser()
            AuthViewModel.shared.updateCurrentUser(user: self.user)
        }
    }
    
    private func save(for type: ProfileSaveType, toggleValue: Bool, completion: @escaping () -> Void) {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        
        switch type {
        case .name:
            guard self.name != "" else { return }
            
            COLLECTION_USERS.document(uid).updateData(["name": self.name]) { _ in
                self.user.name = self.name
                completion()
            }
        case .image:
            guard let image = self.selectedImage else {
                print("DEBUG: image not found.")
                return
            }
            
            ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
                COLLECTION_USERS.document(uid).updateData(["profileImageUrl": imageUrl]) { _ in
                    print("DEBUG: ✅ Succesfully updated profile image ...")
                    self.user.profileImageUrl = imageUrl
                    completion()
                }
            }
        case .bio:
            guard self.bio != "" else { return }
            
            COLLECTION_USERS.document(uid).updateData(["bio": self.bio]) { _ in
                self.user.bio = self.bio
                completion()
            }
        case .instagram:
            guard self.instagramHandle != "" else { return }
            
            COLLECTION_USERS.document(uid).updateData(["instagramHandle": self.instagramHandle]) { _ in
                self.user.instagramHandle = self.instagramHandle
                completion()
            }
            
        case .ageToggle:
            COLLECTION_USERS.document(uid).updateData(["userOptions.showAgeOnProfile": toggleValue]) { _ in
                self.user.userOptions[UserOption.showAgeOnProfile.rawValue] = toggleValue
                completion()
            }
        }
    }
    
    private func cacheUser() {
        Task {
            do {
                try UserCache.shared.cacheUser(self.user)
                print("DEBUG: Cached user after profile update.")
            } catch {
                print("DEBUG: Error caching user on profile.")
            }
        }
    }
    
    func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    
    func getDateJoined() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        let days = formatter.string(from: user.dateJoined.dateValue(), to: Date()) ?? ""
        let date = user.dateJoined.getTimestampString(format: "MMMM d, yyyy")
        
        return "You joined mixer \(days) ago on \(date)."
    }
}
