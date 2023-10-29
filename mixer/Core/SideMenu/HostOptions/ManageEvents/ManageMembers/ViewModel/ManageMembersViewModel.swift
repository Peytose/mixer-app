//
//  ManageMembersViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/21/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

@MainActor
class ManageMembersViewModel: ObservableObject {
    @Published var selectedHost: Host?
    @Published var selectedMember: User?
    @Published private(set) var associatedHosts: [Host]
    
    @Published var username: String = ""
    @Published var memberType: HostMemberType = .member
    @Published var hostUserLinks: [HostUserLink] = []
    @Published var filteredMembers: [User] = []
    @Published var selectedMemberSection: MemberInviteStatus = .invited {
        didSet {
            refreshViewState()
        }
    }
    
    @Published var viewState: ListViewState = .loading
    @Published var isShowingUsernameInputAlert: Bool = false
    
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
    
    private var members: [User] = []
    
    init(associatedHosts: [Host]) {
        self.associatedHosts = associatedHosts
        self.selectedHost = associatedHosts.first
        self.fetchMembers()
        print("DEBUG: Initialized member vm!")
    }
    
    
    func refresh() {
        self.username = ""
        self.fetchMembers()
    }
    
    
    private func refreshViewState() {
        print("DEBUG: Refreshing view state ...")
        let filterLinks = hostUserLinks.filter({ $0.status == self.selectedMemberSection })
        var filteredMembers: [User] = []
        
        for link in filterLinks {
            guard let member = members.first(where: { $0.id == link.id }) else { return }
            filteredMembers.append(member)
            print("DEBUG: Filtered members: \(filteredMembers)")
        }
        
        self.filteredMembers = filteredMembers
        self.viewState = filteredMembers.isEmpty ? .empty : .list
        print("DEBUG: Refreshed view state: \(viewState)\nMembers: \(filteredMembers)")
    }
    
    
    func remove() {
        guard let selectedMember = selectedMember,
              let memberId = selectedMember.id,
              let memberLink = hostUserLinks.first(where: { $0.id == memberId }) else {
            return
        }
        
        switch memberLink.status {
            case .joined:
                confirmationAlertItem = AlertContext.confirmRemoveMember {
                    self.removeMember(with: memberId)
                }
            case .invited:
                self.removeMember(with: memberId)
        }
    }
    
    
    private func removeMember(with id: String) {
        guard let hostId = selectedHost?.id else { return }
        
        COLLECTION_HOSTS
            .document(hostId)
            .collection("member-list")
            .document(id)
            .delete { error in
                if let _ = error {
                    self.showEmptyView()
                    self.alertItem = AlertContext.unableToRemoveMember
                    return
                }
                
                DispatchQueue.main.async {
                    self.members.removeAll(where: { $0.id == id })
                    self.hostUserLinks.removeAll(where: { $0.id == id })
                    self.refreshViewState()
                }
                
                COLLECTION_NOTIFICATIONS
                    .deleteNotifications(forUserID: id,
                                         ofTypes: [.memberJoined,
                                                   .memberInvited],
                                         hostId: hostId) { _ in
                        HapticManager.playLightImpact()
                    }
            }
    }
    
    
    func inviteMember() {
        guard let selectedHost = self.selectedHost, let hostId = selectedHost.id else { return }
        
        if let member = members.first(where: { $0.username == username }),
           let link = self.hostUserLinks.first(where: { $0.id == member.id }) {
            switch link.status {
                case .invited:
                    self.alertItem = AlertContext.duplicateMemberInvite
                case .joined:
                    self.alertItem = AlertContext.memberAlreadyJoined
            }
        } else {
            if username != "" {
                COLLECTION_USERS
                    .whereField("username", isEqualTo: self.username)
                    .limit(to: 1)
                    .getDocuments { snapshot, error in
                        if let _ = error {
                            self.alertItem = AlertContext.unableToGetUserFromUsername
                            return
                        }
                        
                        guard let user = try? snapshot?.documents.first?.data(as: User.self),
                              let userId = user.id else { return }
                        
                        var link = HostUserLink(timestamp: Timestamp(),
                                                status: .invited)
                        
                        guard let encodedLink = try? Firestore.Encoder().encode(link) else { return }
                        
                        COLLECTION_HOSTS
                            .document(hostId)
                            .collection("member-list")
                            .document(userId)
                            .setData(encodedLink) { error in
                                if let _ = error {
                                    self.alertItem = AlertContext.unableToAddMember
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    link.id = userId
                                    self.members.append(user)
                                    self.hostUserLinks.append(link)
                                    self.refreshViewState()
                                }
                                
                                NotificationsViewModel.uploadNotification(toUid: userId,
                                                                          type: .memberInvited,
                                                                          host: selectedHost)
                            }
                    }
            }
        }
    }
    
    
    @MainActor
    func changeHost(to host: Host) {
        self.selectedHost = host
    }
    
    private func showLoadingView() { viewState = .loading }
    private func showEmptyView() { viewState = .empty }
}

// MARK: - Helpers for fetching member list
extension ManageMembersViewModel {
    private func fetchMembers() {
        showLoadingView()
        
        guard let hostId = selectedHost?.id else {
            showEmptyView()
            return
        }
        
        COLLECTION_HOSTS
            .document(hostId)
            .collection("member-list")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    self.showEmptyView()
                    return
                }
                let links = documents.compactMap({ try? $0.data(as: HostUserLink.self) })
                
                let group = DispatchGroup()
                var members: [User] = []
                
                for link in links {
                    group.enter()
                    guard let linkId = link.id else {
                        self.showEmptyView()
                        return
                    }
                    
                    COLLECTION_USERS
                        .document(linkId)
                        .getDocument { snapshot, error in
                            guard let member = try? snapshot?.data(as: User.self) else {
                                self.showEmptyView()
                                return
                            }
                            
                            members.append(member)
                            print("DEBUG: Member: \(member)")
                            group.leave()
                        }
                }
                
                group.notify(queue: .main) {
                    self.hostUserLinks = links
                    self.members = members
                    
                    if links.filter({ $0.status == .invited }).count > 0 && self.selectedMemberSection != .invited {
                        self.selectedMemberSection = .invited
                    } else if links.filter({ $0.status == .joined }).count > 0 && self.selectedMemberSection != .joined {
                        self.selectedMemberSection = .joined
                    }
                    
                    self.refreshViewState()
                }
            }
    }
}
