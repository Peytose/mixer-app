//
//  ProfileViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import Firebase

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var showSettingsView     = false
    @Published var showUnfriendAlert    = false
    @Published var continueUnfriendFunc = false
    @Published var eventSection         = EventSection.interests
    @Published var savedEvents          = [CachedEvent]()
    @Published var pastEvents           = [CachedEvent]()
    
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
    
    
    init(user: User) {
        self.user = user
        getUserRelationship()
        print("DEBUG: profile init ran")
        //        fetchUsersStats()
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
                self.savedEvents = try await EventCache.shared.fetchSavedEvents(for: uid)
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
}
