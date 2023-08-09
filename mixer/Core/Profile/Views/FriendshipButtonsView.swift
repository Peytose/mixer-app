//
//  FriendshipButtonsView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import SwiftUI

struct FriendshipButtonsView: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if viewModel.user.friendshipState != .requestReceived {
                mainButton
            }
            
            if viewModel.user.friendshipState == .requestReceived {
                acceptButton
                rejectButton
            }
        }
    }
}

extension FriendshipButtonsView {
    @ViewBuilder
    private var mainButton: some View {
        Button {
            switch viewModel.user.friendshipState {
            case .friends, .requestSent:
                viewModel.cancelFriendRequest()
            case .notFriends:
                viewModel.sendFriendRequest()
            default:
                break
            }
        } label: {
            Text(viewModel.user.friendshipState?.text ?? "")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                .background {
                    Capsule().stroke()
                }
        }
        .buttonStyle(.plain)
    }
    
    private var acceptButton: some View {
        Button(action: viewModel.acceptFriendRequest) {
            Text("Accept")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                .background {
                    Capsule().stroke()
                }
        }
        .buttonStyle(.plain)
    }
    
    private var rejectButton: some View {
        Button(action: viewModel.cancelFriendRequest) {
            Text("Reject")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                .background {
                    Capsule().stroke()
                }
        }
        .buttonStyle(.plain)
    }
}

struct FriendshipButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendshipButtonsView()
            .environmentObject(ProfileViewModel(user: dev.mockUser))
    }
}
