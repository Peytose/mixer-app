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
    @StateObject private var settingsViewModel      = SettingsViewModel()
    @StateObject private var notificationsViewModel = NotificationsViewModel()
    private let hostFormLink = "https://forms.gle/S3jmgEGSa3VU1Vi56"
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Header view
            VStack(alignment: .leading, spacing: 32) {
                // user info
                HStack(alignment: .center, spacing: 15) {
                    if let user = settingsViewModel.user {
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
                Button { openHostFormLink() } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Promote your own events!")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "music.note.house")
                                .font(.title2)
                                .imageScale(.medium)
                            
                            Text("Become A Host")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
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
                if settingsViewModel.user?.accountType == .member || settingsViewModel.user?.accountType == .host {
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
                                    CustomBadgeModifier(value: .constant(notificationsViewModel.notifications.count))
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
                        .environmentObject(EventCreationViewModel())
                case .manageGuestlists:
                    GuestlistView(hosts: settingsViewModel.user?.associatedHosts ?? [])
                case .manageMembers:
                    ManageMembersView(hosts: settingsViewModel.user?.associatedHosts ?? [])
                }
            }
            .navigationDestination(for: SideMenuOption.self) { option in
                switch option {
                case .notifications:
                    NotificationsView(viewModel: notificationsViewModel, path: $path)
                case .favorites:
                    FavoritesView(path: $path)
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

extension SideMenuView {
    private func openHostFormLink() {
        if let url = URL(string: hostFormLink) {
            UIApplication.shared.open(url)
        }
    }
}
