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
            .sheet(isPresented: $viewModel.isShowingUsernameInputSheet) {
                NavigationStack {
                    ZStack {
                        Color.theme.backgroundColor
                            .ignoresSafeArea()
                        
                        List(viewModel.userResults) { result in
                            ItemInfoCell(title: result.title,
                                         subtitle: result.subtitle,
                                         imageUrl: result.imageUrl)
                            .listRowBackground(Color.theme.secondaryBackgroundColor)
                            .onTapGesture {
                                viewModel.inviteMember(with: result.subtitle)
                                viewModel.isShowingUsernameInputSheet = false
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.insetGrouped)
                        .searchable(text: $viewModel.searchText)
                        .navigationTitle("Search Users")
                        
                        Spacer()
                    }
                }
                .overlay(alignment: .topTrailing) {
                    XDismissButton { viewModel.isShowingUsernameInputSheet = false }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .overlay(alignment: .topLeading) {
            PresentationBackArrowButton()
                .padding()
        }
        .overlay(alignment: .topTrailing) {
            if let hostId = viewModel.selectedHost?.id,
               let privileges = UserService.shared.user?.hostIdToMemberTypeMap?[hostId]?.privileges,
               privileges.contains(.inviteMembers) {
                AddMemberButton(showAlert: $viewModel.isShowingUsernameInputSheet)
                    .padding()
            }
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
        .listStyle(.insetGrouped)
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
