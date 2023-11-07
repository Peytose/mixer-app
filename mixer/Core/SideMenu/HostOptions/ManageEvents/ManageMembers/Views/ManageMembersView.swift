//
//  ManageMembersView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/21/23.
//

import SwiftUI

struct ManageMembersView: View {
    @StateObject var viewModel: ManageMembersViewModel
    
    init(hosts: [Host]) {
        _viewModel = StateObject(wrappedValue: ManageMembersViewModel(associatedHosts: hosts))
    }

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                HostTitleView(hosts: viewModel.associatedHosts,
                              selectedHost: viewModel.selectedHost) { host in
                    viewModel.changeHost(to: host)
                }
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                AddMemberButton(showAlert: $viewModel.isShowingUsernameInputAlert)
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
        ManageMembersView(hosts: [dev.mockHost])
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


fileprivate struct HostTitleView: View {
    let hosts: [Host]
    let selectedHost: Host?
    let action: (Host) -> Void

    var body: some View {
        if !hosts.isEmpty, hosts.count > 1 {
            Menu {
                ForEach(hosts) { host in
                    Button(host.name) { action(host) }
                }
            } label: {
                VStack {
                    Text((selectedHost?.name ?? "") + "'s")
                        .fontWeight(.medium)
                        .foregroundColor(Color.theme.mixerIndigo)
                    +
                    Text("Members")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .font(.title)
                .multilineTextAlignment(.leading)
            }
        } else {
            Text((selectedHost?.name ?? "") + "'s Members")
                .primaryHeading()
                .multilineTextAlignment(.leading)
        }
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
