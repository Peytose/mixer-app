//
//  RelationshipButtonsView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import SwiftUI

struct RelationshipButtonsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if viewModel.user.relationshipState != .requestReceived {
                mainButton
            }
            
            if viewModel.user.relationshipState == .requestReceived {
                acceptButton
                rejectButton
            }
        }
    }
}

extension RelationshipButtonsView {
    @ViewBuilder
    private var mainButton: some View {
        Button {
            switch viewModel.user.relationshipState {
            case .friends, .requestSent, .blocked:
                viewModel.cancelRelationshipRequest()
            case .notFriends:
                viewModel.sendFriendRequest()
            default:
                break
            }
        } label: {
            Text(viewModel.user.relationshipState?.text ?? "")
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
        Button(action: viewModel.cancelRelationshipRequest) {
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
