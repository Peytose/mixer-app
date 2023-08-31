//
//  MemberRow.swift
//  mixer
//
//  Created by Peyton Lyons on 8/22/23.
//

import SwiftUI

struct MemberRow: View {
    @EnvironmentObject var viewModel: ManageMembersViewModel
    let member: User
    let link: HostUserLink
    
    var subtitle: String {
        var text = link.status.description + " "
        guard let date = link.timestamp else { return "" }
        return text + date.notificationTimeString() + " ago"
    }

    var body: some View {
        SearchResultsCell(imageUrl: member.profileImageUrl,
                          title: member.displayName,
                          subtitle: subtitle)
        .listRowBackground(Color.theme.backgroundColor)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation() {
                viewModel.selectedMember = member
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.selectedMember = member
                viewModel.remove()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
}

struct MemberRow_Previews: PreviewProvider {
    static var previews: some View {
        MemberRow(member: dev.mockUser, link: HostUserLink(status: .invited))
    }
}
