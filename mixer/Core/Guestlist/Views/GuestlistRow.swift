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

                    if let status = guest.status, status == .checkedIn {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.theme.mixerIndigo)
                            .frame(width: 20, height: 20)
                    }
                }
            }

            Spacer()

            Image(systemName: "graduationcap.fill")
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)

            Text(guest.university)
                .subheadline()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
        .contentShape(Rectangle())
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

struct GuestlistRow_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistRow(guest: EventGuest(from: dev.mockUser))
    }
}
