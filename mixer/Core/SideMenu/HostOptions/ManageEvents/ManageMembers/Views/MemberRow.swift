//
//  MemberRow.swift
//  mixer
//
//  Created by Peyton Lyons on 8/22/23.
//

import SwiftUI

struct MemberRow: View {
    @EnvironmentObject var viewModel: ManageMembersViewModel
    @State private var showActionSheet = false
    let member: User
    let link: HostUserLink
    
    var subtitle: String {
        let text = link.status.description + " "
        guard let date = link.timestamp else { return "" }
        return text + date.notificationTimeString() + " ago"
    }

    var body: some View {
        HStack(alignment: .center) {
            SearchResultsCell(imageUrl: member.profileImageUrl,
                              title: member.displayName,
                              subtitle: subtitle)
            
            if link.status == .joined {
                EllipsisButton {
                    showActionSheet = true
                }
            }
        }
        .listRowBackground(Color.theme.backgroundColor)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let memberId = member.id {
                    viewModel.removeMember(with: memberId)
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            viewModel.actionSheet(member)
        }
    }
}

struct MemberRow_Previews: PreviewProvider {
    static var previews: some View {
        MemberRow(member: dev.mockUser, link: HostUserLink(status: .invited))
    }
}
