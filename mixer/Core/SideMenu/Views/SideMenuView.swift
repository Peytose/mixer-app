//
//  SideMenuView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import UIKit
import SwiftUI
import Kingfisher

struct SideMenuView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @StateObject private var settingsViewModel      = SettingsViewModel()
    @StateObject private var notificationsViewModel = NotificationsViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Header view
            VStack(alignment: .leading, spacing: 32) {
                // user info
                if let user = settingsViewModel.user {
                    NavigationLink {
                        ProfileView(user: user)
                    } label: {
                        HStack(alignment: .center, spacing: 15) {
                            KFImage(URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 64, height: 64)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(user.displayName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .opacity(0.77)
                            }
                        }
                    }
                    
                    // Become a host
                    HostMenuView(viewModel: homeViewModel,
                                 memberHosts: settingsViewModel.user?.associatedHosts ?? [])
                }
                
                Rectangle()
                    .frame(width: 296, height: 0.75)
                    .opacity(0.7)
                    .foregroundColor(Color(.separator))
                    .shadow(color: .black.opacity(0.7), radius: 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            
            // MARK: - Side menu options
            VStack(alignment: .leading) {
                if settingsViewModel.user?.hostIdToMemberTypeMap != nil {
                    ForEach(HostSideMenuOption.allCases) { option in
                        NavigationLink(value: option) {
                            SideMenuOptionView(option: option)
                                .padding()
                        }
                    }
                }
                
                ForEach(SideMenuOption.allCases) { option in
                    NavigationLink(value: option) {
                        if option == .notifications {
                            SideMenuOptionView(option: option)
                                .overlay {
                                    CustomBadgeModifier(value: .constant(notificationsViewModel.numberOfNewNotifications()))
                                }
                                .padding()
                        } else {
                            SideMenuOptionView(option: option)
                                .padding()
                        }
                    }
                }
            }
            .navigationDestination(for: HostSideMenuOption.self) { option in
                switch option {
                case .createEvent:
                    EventCreationFlowView()
                case .manageMembers:
                    ManageMembersView()
                case .manageEvents:
                    ManageEventsView()
                }
            }
            .navigationDestination(for: SideMenuOption.self) { option in
                switch option {
                case .notifications:
                    NotificationsView(viewModel: notificationsViewModel)
                        .onAppear {
                            notificationsViewModel.saveCurrentTimestamp()
                        }
                case .favorites:
                    FavoritesView()
                case .mixerId:
                    if let user = settingsViewModel.user, let image = user.id?.generateQRCode() {
                        MixerIdView(user: user,
                                    image: Image(uiImage: image))
                    }
                case .settings:
                    SettingsView(viewModel: settingsViewModel)
                }
            }
            
            Spacer()
        }
        .padding(.top, 32)
        .background(Color.theme.backgroundColor)
    }
}

struct HostMenuView: View {
    @ObservedObject var viewModel: HomeViewModel
    var memberHosts: [Host]

    var body: some View {
        Group {
            if !memberHosts.isEmpty {
                Menu {
                    ForEach(memberHosts) { host in
                        Button {
                            viewModel.selectHost(host)
                        } label: {
                            HStack {
                                Text(host.name)
                                
                                if host.username == UserService.shared.user?.currentHost?.username {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    hostTextView
                }
            } else {
                Button(action: openHostFormLink) {
                    hostTextView
                }
            }
        }
    }

    private var hostTextView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if memberHosts.isEmpty {
                Text("Promote your own events!")
                    .font(.footnote)
                    .fontWeight(.semibold)
            }

            HStack {
                Image(systemName: "house\(memberHosts.isEmpty ? "" : ".fill")")
                    .font(.title2)
                    .imageScale(.medium)
                
                Text(memberHosts.isEmpty ? "Become A Host" : (viewModel.currentHost?.name ?? "n/a"))
                    .font(.headline)
                
                if memberHosts.count > 1 {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
            }
        }
        .foregroundColor(.white)
    }
    
    
    private func openHostFormLink() {
        if let url = URL(string: "https://forms.gle/S3jmgEGSa3VU1Vi56") {
            UIApplication.shared.open(url)
        }
    }
}
