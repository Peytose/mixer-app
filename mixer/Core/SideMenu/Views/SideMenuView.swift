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
    @Binding var user: User?
    private let hostFormLink = "https://forms.gle/S3jmgEGSa3VU1Vi56"
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Header view
            VStack(alignment: .leading, spacing: 32) {
                // user info
                HStack(alignment: .center, spacing: 15) {
                    if let user = user {
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
                if user?.accountType == .member || user?.accountType == .host {
                    ForEach(HostSideMenuOption.allCases) { option in
                        NavigationLink(value: option) {
                            SideMenuOptionView(option: option)
                                .padding()
                        }
                    }
                }
                
                ForEach(SideMenuOption.allCases) { option in
                    NavigationLink(value: option) {
                        SideMenuOptionView(option: option)
                            .padding()
                    }
                }
            }
            .navigationDestination(for: HostSideMenuOption.self) { option in
                switch option {
                    case .createEvent:
                    EventCreationFlowView()
                        .environmentObject(EventCreationViewModel())
                    case .manageGuestlists:
                        Text(option.title)
                    case .manageMembers:
                        Text(option.title)
                }
            }
            .navigationDestination(for: SideMenuOption.self) { option in
                switch option {
                case .favorites:
                    FavoritesView()
                case .mixerId:
                    if let user = user, let image = user.id?.generateQRCode() {
                        MixerIdView(user: user,
                                    image: Image(uiImage: image))
                    }
                case .settings:
                    if let user = user {
                        SettingsView(user: user)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.top, 32)
        .background(Color.theme.backgroundColor)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SideMenuView(user: .constant(dev.mockUser))
        }
    }
}

extension SideMenuView {
    private func openHostFormLink() {
        if let url = URL(string: hostFormLink) {
            UIApplication.shared.open(url)
        }
    }
}
