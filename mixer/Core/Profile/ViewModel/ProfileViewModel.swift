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
    @Published var favoritedEvents      = [Event]()
    @Published var pastEvents           = [Event]()
    @Published var mutuals              = [User]()
    
    @Published var currentAlert: AlertType?
    @Published var alertItem: AlertItem? {
        didSet {
            currentAlert = .regular(alertItem)
        }
    }
    @Published var confirmationAlertItem: ConfirmationAlertItem? {
        didSet {
            currentAlert = .confirmation(confirmationAlertItem)
        }
    }
    
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
        self.getUserRelationship()
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
                                .fill(Color.theme.mixerIndigo)
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
    
    
    @MainActor func sendFriendRequest() {
        guard let uid = user.id else { return }
        UserService.shared.sendFriendRequest(username: user.username, uid: uid) { _ in
            self.user.friendshipState = .requestSent
            HapticManager.playSuccess()
        }
    }
    
    
    @MainActor func acceptFriendRequest() {
        guard let uid = user.id else { return }
        UserService.shared.acceptFriendRequest(uid: uid) { _ in
            self.user.friendshipState = .friends
            HapticManager.playSuccess()
        }
    }
    
    
    @MainActor func cancelFriendRequest() {
        guard let uid = user.id else { return }
        guard let state = user.friendshipState else { return }
        
        switch state {
        case .friends:
            self.confirmationAlertItem = AlertContext.confirmRemoveFriend {
                UserService.shared.cancelRequestOrRemoveFriend(uid: uid) { _ in
                    self.user.friendshipState = .notFriends
                    HapticManager.playLightImpact()
                }
            }
        case .requestReceived, .requestSent:
            UserService.shared.cancelRequestOrRemoveFriend(uid: uid) { _ in
                self.user.friendshipState = .notFriends
                HapticManager.playLightImpact()
            }
        default: break
        }
    }
    
    
    func getUserRelationship() {
        guard !user.isCurrentUser else {
            print("DEBUG: This is the current user's profile!")
            return
        }
        
        guard let uid = user.id else { return }
        
        UserService.shared.getUserRelationship(uid: uid) { relation in
            self.user.friendshipState = relation
            print("DEBUG: relation to user. \(relation)")
        }
    }
    
    
//    @MainActor func getProfileEvents() {
//        print("DEBUG: Getting profile events ...")
//        if user.friendshipState != .friends && user.id != AuthViewModel.shared.currentUser?.id {
//            print("DEBUG: Profile not a friend or self!")
//            return
//        }
//
//        guard let uid = user.id else { return }
//
//        COLLECTION_EVENTS
//            .whereField("favoritedBy", arrayContains: uid)
//            .getDocuments { snapshot, _ in
//                guard let documents = snapshot?.documents else { return }
//                let events = documents.compactMap({ try? $0.data(as: Event.self) })
//                self.favoritedEvents = events
//            }
//    }
}
