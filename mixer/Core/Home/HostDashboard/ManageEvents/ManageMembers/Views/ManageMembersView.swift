//
//  ManageMembersView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/21/23.
//

import SwiftUI

struct ManageMembersView: View {
    @StateObject var viewModel = ManageMembersViewModel()
    @State private var selectedMember: SearchItem? = nil
    @State private var showInviteAlert: Bool = false 
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                StickyHeaderView(items: MemberInviteStatus.allCases,
                                 selectedItem: $viewModel.selectedMemberSection)
                
                switch viewModel.viewState {
                case .loading:
                    LoadingView()
                case .empty:
                    emptyView
                    Spacer()
                case .list:
                    membersListView
                }
            }
            .fullScreenCover(isPresented: $viewModel.isShowingUsernameInputSheet) {
                NavigationStack {
                    ZStack {
                        Color.theme.backgroundColor
                            .ignoresSafeArea()
                        
                        List(viewModel.userResults) { result in
                            if !viewModel.searchText.isEmpty {
                                ItemInfoCell(title: result.title,
                                             subtitle: "@\(result.subtitle)",
                                             imageUrl: result.imageUrl)
                                .onTapGesture {
                                    self.selectedMember = result
                                    self.showInviteAlert = true
                                }
                                .listRowBackground(Color.theme.secondaryBackgroundColor)
                                .alert(isPresented: $showInviteAlert) {
                                    // Safely unwrap selectedMember within the alert
                                    if let member = selectedMember {
                                        return Alert(
                                            title: Text("Invite @\(member.subtitle) to organization"),
                                            primaryButton: .default(Text("Yes"), action: {
                                                viewModel.inviteMember(with: member.subtitle)
                                                viewModel.isShowingUsernameInputSheet = false
                                            }),
                                            secondaryButton: .cancel()
                                        )
                                    } else {
                                        return Alert(title: Text("Error"), message: Text("Something went wrong. Please try again."))
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.insetGrouped)
                        .searchable(text: $viewModel.searchText)
                        .navigationTitle("Search Users")
                    }
                }
                .overlay(alignment: .topTrailing) {
                    XDismissButton { viewModel.isShowingUsernameInputSheet = false }
                        .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBar(title: "Manage Members", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                PresentationBackArrowButton()
            }
            if let hostId = viewModel.selectedHost?.id,
               let privileges = UserService.shared.user?.hostIdToMemberTypeMap?[hostId]?.privileges,
               privileges.contains(.inviteMembers) {
                ToolbarItem(placement: .topBarTrailing) {
                    AddMemberButton(showAlert: $viewModel.isShowingUsernameInputSheet)
                }
                
            }
        }
        .withAlerts(currentAlert: $viewModel.currentAlert)
    }
}


struct ManageMembersView_Previews: PreviewProvider {
    static var previews: some View {
        ManageMembersView()
    }
}

extension ManageMembersView {
    var emptyView: some View {
        Group {
            if let selectedHost = viewModel.selectedHost {
                switch viewModel.selectedMemberSection {
                case .invited:
                    Text("Tap '+' to invite a user to \(selectedHost.name)!")
                        .multilineTextAlignment(.center)
                case .joined:
                    Text("Currently empty ...")
                }
            }
        }
        .foregroundColor(.secondary)
        .padding(.top)
    }
    
    var membersListView: some View {
        List(viewModel.filteredMembers) { member in
            if let link = viewModel.hostUserLinks.first(where: { $0.id == member.id }) {
                MemberRow(member: member, link: link)
                    .environmentObject(viewModel)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }
}

fileprivate struct AddMemberButton: View {
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            HapticManager.playLightImpact()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                showAlert = true
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(Color.theme.backgroundColor)
                .padding(10)
                .background {
                    Circle()
                        .foregroundColor(Color.white)
                        .shadow(radius: 20)
                }
        }
    }
}
