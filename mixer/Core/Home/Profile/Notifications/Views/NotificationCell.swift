//
//  NotificationCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import Kingfisher
import Firebase

struct NotificationCell: View {
    
    @EnvironmentObject var viewModel: NotificationsViewModel
    
    @ObservedObject var cellViewModel: NotificationCellViewModel
    @ObservedObject var sharedData: SharedNotificationDataStore = .shared
    
    var isFollowed: Bool { return cellViewModel.notification.isFollowed ?? false }
    
    @Namespace var namespace
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack {
                NavigationLink {
                    switch cellViewModel.notification.type {
                    case .friendAccepted,
                            .friendRequest,
                            .newFollower,
                            .eventLiked,
                            .memberInvited,
                            .memberJoined,
                            .guestlistJoined,
                            .plannerInvited,
                            .plannerAccepted,
                            .plannerDeclined,
                            .plannerReplaced,
                            .plannerRemoved,
                            .plannerPendingReminder,
                            .hostInvited:
                        if let user = sharedData.users[cellViewModel.notification.uid] {
                            ProfileView(user: user)
                        }
                    case .guestlistAdded:
                        if let host = sharedData.hosts[cellViewModel.notification.hostId ?? ""] {
                            HostDetailView(host: host, namespace: namespace)
                        }
                    case .eventPostedWithoutPlanner:
                        if let event = sharedData.events[cellViewModel.notification.eventId ?? ""] {
                            EventDetailView(event: event, namespace: namespace)
                        }
                    default: EmptyView()
                    }
                } label: {
                    HStack {
                        ProfileImageViews(imageUrlsString: cellViewModel.notification.imageUrl)

                        Group {
                            VStack(alignment: .leading) {
                                formattedNotificationMessage
                            }
                        }
                        .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.borderless)
            }
            
            Spacer()
            
            // Side button(s)
            Group {
                switch cellViewModel.notification.type {
                case .friendRequest, .memberInvited:
                    HStack(spacing: 15) {
                        ListCellActionButton(text: "checkmark",
                                             isIcon: true) {
                            if cellViewModel.notification.type == .friendRequest {
                                cellViewModel.acceptFriendRequest()
                            } else if cellViewModel.notification.type == .memberInvited {
                                cellViewModel.acceptMemberInvite(host: sharedData.hosts[cellViewModel.notification.hostId ?? ""])
                            }
                        }
                        
                        ListCellActionButton(text: "xmark",
                                             isIcon: true,
                                             isSecondaryLabel: true) {
                            if cellViewModel.notification.type == .friendRequest {
                                cellViewModel.cancelOrDeleteRelationship()
                            } else if cellViewModel.notification.type == .memberInvited {
                                cellViewModel.declineMemberInvite()
                            }
                        }
                    }
                case .eventLiked, .guestlistAdded:
                    if let event = sharedData.events[cellViewModel.notification.eventId ?? ""] {
                        NavigationLink {
                            EventDetailView(event: event, namespace: namespace)
                        } label: {
                            NotificationSecondaryImage(imageUrl: event.eventImageUrl) { }
                        }
                    }
                case .guestlistJoined:
                    ListCellActionButton(text: "Remove") {
                        cellViewModel.removeFromGuestlist()
                    }
                case .plannerInvited, .plannerPendingReminder:
                    HStack {
                        ListCellActionButton(text: "Accept") {
                            cellViewModel.acceptPlannerInvite(event: sharedData.events[cellViewModel.notification.eventId ?? ""])
                        }
                        
                        ListCellActionButton(text: "xmark",
                                             isIcon: true,
                                             isSecondaryLabel: true) {
                            cellViewModel.declinePlannerInvite(event: sharedData.events[cellViewModel.notification.eventId ?? ""])
                        }
                    }
                case .plannerDeclined:
                    ListCellActionButton(text: "Remove") {
                        cellViewModel.removePlanner(event: sharedData.events[cellViewModel.notification.eventId ?? ""])
                    }
                case .hostInvited:
                    ListCellActionButton(text: "chevron.right",
                                             isIcon: true) {
                        if let notificationId = cellViewModel.notification.id {
                            viewModel.showCreateHost(notificationId: notificationId)
                        }
                    }
                default: Text("")
                }
            }
        }
        .padding(.trailing)
        .padding(.bottom)
    }
}

#Preview("Notification Cell", body: {
    NavigationStack {
        NotificationCell(cellViewModel: NotificationCellViewModel(notification: Notification(uid: "", headline: "Peyton", timestamp: Timestamp(), expireAt: Timestamp(), imageUrl: "", type: .hostInvited)))
    }
})

fileprivate struct NotificationSecondaryImage: View {
    let imageUrl: String
    let action: () -> Void
    
    var body: some View {
        Button { action() } label: {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.borderless)
    }
}

fileprivate struct ProfileImageViews: View {
    let imageUrlsString: String
    private let imageSize: CGFloat = 35
    private let overlapOffset: CGFloat = 10

    var body: some View {
        HStack(spacing: -overlapOffset) {
            ForEach(imageUrls, id: \.self) { imageUrl in
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(Circle())
            }
        }
    }

    private var imageUrls: [String] {
        imageUrlsString.components(separatedBy: "!!!").reversed()
    }
}

extension NotificationCell {
    private var formattedNotificationMessage: Text {
        var message = Text(cellViewModel.notification.headline)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(Color.theme.mixerIndigo)

        message = message + Text(cellViewModel.notification.type.notificationMessage(cellViewModel.notification.count))
            .font(.subheadline)
            .foregroundColor(.white)
        
        switch cellViewModel.notification.type {
            case .eventLiked,
                    .guestlistJoined,
                    .guestlistAdded,
                    .plannerInvited,
                    .plannerAccepted,
                    .plannerDeclined,
                    .plannerReplaced,
                    .plannerRemoved,
                    .plannerPendingReminder:
            message = message + Text(sharedData.events[cellViewModel.notification.eventId ?? ""]?.title ?? "")
                .font(.subheadline)
                    .foregroundColor(.white)
            case .memberInvited,
                    .memberJoined:
            message = message + Text(sharedData.hosts[cellViewModel.notification.hostId ?? ""]?.name ?? "")
                .font(.subheadline)
                    .foregroundColor(.white)
            default: break
        }

        return message +                         Text(" \(cellViewModel.notification.timestampString) ago")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}
