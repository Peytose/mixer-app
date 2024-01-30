//
//  ManageMembersView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/21/23.
//

import SwiftUI

struct ManageMembersView: View {
    @StateObject var viewModel = ManageMembersViewModel()

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                Text("Members of \(viewModel.selectedHost?.name ?? "n/a")")
                    .primaryHeading()
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: DeviceTypes.ScreenSize.width, alignment: .leading)
                    .padding([.leading, .top])
                
                StickyHeaderView(items: MemberInviteStatus.allCases,
                                 selectedItem: $viewModel.selectedMemberSection)
                
                switch viewModel.viewState {
                case .loading:
                    LoadingView()
                case .empty:
                    emptyView
                case .list:
                    membersListView
                }
                
                Spacer()
            }
            .alert("Invite a Member", isPresented: $viewModel.isShowingUsernameInputAlert) {
                TextField("Type username here...", text: $viewModel.username)
                    .foregroundColor(.primary)
                
                if #available(iOS 16.0, *) {
                    Button("Invite") { viewModel.inviteMember() }
                        .tint(.secondary)
                    Button("Cancel", role: .cancel, action: {})
                        .tint(.white)
                }
            } message: {
                Text("")
            }
            .padding(.top, 50)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .overlay(alignment: .topLeading) {
            PresentationBackArrowButton()
                .padding()
        }
        .overlay(alignment: .topTrailing) {
            if let hostId = viewModel.selectedHost?.id, (UserService.shared.user?.hostIdToMemberTypeMap?[hostId]?.privilege ?? .basic).rawValue > PrivilegeLevel.basic.rawValue {
                AddMemberButton(showAlert: $viewModel.isShowingUsernameInputAlert)
                    .padding()
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
        List {
            ForEach(viewModel.filteredMembers) { member in
                if let link = viewModel.hostUserLinks.first(where: { $0.id == member.id }) {
                    MemberRow(member: member, link: link)
                        .environmentObject(viewModel)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
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
