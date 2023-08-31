//
//  GuestlistRow.swift
//  mixer
//
//  Created by Peyton Lyons on 8/12/23.
//

import SwiftUI

struct GuestlistRow: View {
    @EnvironmentObject var viewModel: GuestlistViewModel
    let guest: EventGuest

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AvatarView(url: guest.profileImageUrl, size: 30)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Text(guest.name.capitalized)
                        .body(color: .white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if guest.gender.icon != "" {
                        Image(guest.gender.icon)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    }

                    if guest.status == .checkedIn {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.theme.mixerIndigo)
                            .frame(width: 20, height: 20)
                    }
                }
            }

            Spacer()
            
            if let university = guest.university, let icon = university.icon {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
                
                Text(university.shortName ?? university.name)
                    .subheadline()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
        .onTapGesture {
            withAnimation() {
                viewModel.isShowingUserInfoModal = true
                viewModel.selectedGuest = guest
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                viewModel.selectedGuest = guest
                viewModel.remove()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .leading) {
            if guest.status == .invited {
                Button {
                    viewModel.selectedGuest = guest
                    viewModel.checkIn()
                } label: {
                    Label("Check-in", systemImage: "list.bullet.clipboard.fill")
                }
            }
        }
    }
}
