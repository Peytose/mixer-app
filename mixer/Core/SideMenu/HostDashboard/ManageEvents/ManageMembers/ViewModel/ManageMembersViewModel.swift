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
    @Published var username: String = ""
    @Published var memberType: HostMemberType = .member
    @Published var hostUserLinks: [HostUserLink] = [] {
        didSet {
            refreshViewState()
        }
    }
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
    
    init() {
        self.selectedHost = UserService.shared.user?.currentHost
        self.fetchMembers()
    }
    
    
    func refresh() {
        self.username = ""
        self.fetchMembers()
    }
    
    
    private func refreshViewState() {
        let filteredLinks = hostUserLinks.filter({ $0.status == self.selectedMemberSection })
        var filteredMembers: [User] = []
        
        for link in filteredLinks {
            if let member = members.first(where: { $0.id == link.id }) {
                filteredMembers.append(member)
            }
        }
        
        self.filteredMembers = filteredMembers
        self.viewState = filteredMembers.isEmpty ? .empty : .list
    }
    
    
    func removeMember(with memberId: String) {
        guard let memberLink = hostUserLinks.first(where: { $0.id == memberId }),
              let selectedHost = self.selectedHost else { return }
        
        print("DEBUG: Removing member with id: \(memberId)\nand link: \(memberLink)")
        
        let removeMemberAction = {
            HostService.shared.removeMember(from: selectedHost, memberId: memberId) { [weak self] error in
                if let _ = error {
                    self?.showEmptyView()
                    self?.alertItem = AlertContext.unableToRemoveMember
                } else {
                    self?.removeMemberFromLocalState(memberId)
                }
            }
        }
        
        switch memberLink.status {
            case .joined:
                confirmationAlertItem = AlertContext.confirmRemoveMember(confirmAction: removeMemberAction)
            case .invited:
                removeMemberAction()
        }
    }

    
    private func removeMemberFromLocalState(_ id: String) {
        DispatchQueue.main.async {
            self.members.removeAll(where: { $0.id == id })
            self.hostUserLinks.removeAll(where: { $0.id == id })
            self.refreshViewState()
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
    
    
    func actionSheet(_ member: User) -> ActionSheet {
        var buttons: [ActionSheet.Button] = []
        
        // Check for selectedHost's ID
        guard let hostId = self.selectedHost?.id else {
            print("DEBUG: No selectedHost id available")
            return ActionSheet(title: Text("No Actions Available"))
        }
        
        // Check for selectedMember
        guard let memberId = member.id else {
            print("DEBUG: No selectedMember id available")
            return ActionSheet(title: Text("No Actions Available"))
        }
        
        // Check for memberRole
        guard let memberRole = member.hostIdToMemberTypeMap?[hostId] else {
            print("DEBUG: No memberRole available")
            return ActionSheet(title: Text("No Actions Available"))
        }
        
        // Check for currentUserRole
        guard let currentUserRole = UserService.shared.user?.hostIdToMemberTypeMap?[hostId] else {
            print("DEBUG: No currentUserRole available")
            return ActionSheet(title: Text("No Actions Available"))
        }
        
        // Check privilege level
        guard currentUserRole.privilege.rawValue > memberRole.privilege.rawValue else {
            print("DEBUG: currentUserRole does not have higher privilege than memberRole")
            return ActionSheet(title: Text("No Actions Available"))
        }
        
        // Add buttons for roles less privileged than the current user's role
        let validRoles = HostMemberType.allCases.filter( {
            $0.privilege.rawValue <= currentUserRole.privilege.rawValue &&
            $0 != memberRole
        })
        
        for role in validRoles {
            buttons.append(.default(Text("Assign as \(role.description)")) {
                // Assign role action
                self.assignRole(role, to: memberId)
            })
        }
        
        // If the current user can delete users, add a delete button
        if currentUserRole.privilege == .admin {
            buttons.append(.destructive(Text("Delete Member")) {
                // Delete member action
                self.removeMember(with: memberId)
            })
        }
        
        // Cancel button
        buttons.append(.cancel())
        
        return ActionSheet(title: Text("Manage Member"), message: nil, buttons: buttons)
    }
    
    private func showLoadingView() { viewState = .loading }
    private func showEmptyView() { viewState = .empty }
}

// MARK: - Helpers for fetching member list
extension ManageMembersViewModel {
    private func assignRole(_ role: HostMemberType, to userId: String) {
        guard let hostId = self.selectedHost?.id else { return }
        let data = ["hostIdToMemberTypeMap": [hostId: role.rawValue]]
        guard let encodedData = try? Firestore.Encoder().encode(data) else { return }
        
        COLLECTION_USERS
            .document(userId)
            .setData(encodedData, merge: true) { error in
                if let error = error {
                    print("DEBUG: Error assigning role to member: \(error.localizedDescription)")
                    return
                }
                
                if let index = self.filteredMembers.firstIndex(where: { $0.id == userId }) {
                    self.filteredMembers[index].hostIdToMemberTypeMap?[hostId] = role
                }
            }
    }
    
    
    private func fetchMembers() {
        showLoadingView()
        
        guard let hostId = self.selectedHost?.id else {
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
                    
                    if linkId == UserService.shared.user?.id {
                        group.leave()
                    } else {
                        COLLECTION_USERS
                            .document(linkId)
                            .getDocument { snapshot, error in
                                guard let member = try? snapshot?.data(as: User.self) else {
                                    self.showEmptyView()
                                    return
                                }
                                
                                members.append(member)
                                group.leave()
                            }
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
