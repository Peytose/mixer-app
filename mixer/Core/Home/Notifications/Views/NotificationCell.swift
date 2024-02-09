//
//  NotificationCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import Kingfisher

struct NotificationCell: View {
    
    @EnvironmentObject var viewModel: NotificationsViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @ObservedObject var cellViewModel: NotificationCellViewModel
    @ObservedObject var sharedData: SharedNotificationDataStore = .shared
    
    var isFollowed: Bool { return cellViewModel.notification.isFollowed ?? false }
    
    @Namespace var namespace
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: cellViewModel.notification.type.category.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background {
                        Circle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(Color.secondary.opacity(0.4))
                    }
                    .padding(.trailing, 8)
            
            VStack(alignment: .leading) {
                Button {
                    switch cellViewModel.notification.type {
                    case .friendAccepted,
                            .friendRequest,
                            .newFollower,
                            .eventLiked,
                            .memberInvited,
                            .memberJoined,
                            .guestlistJoined,
                            .plannerAccepted,
                            .plannerDeclined,
                            .plannerReplaced,
                            .plannerRemoved,
                            .plannerPendingReminder:
                        homeViewModel.navigate(to: .close,
                                               withUser: sharedData.users[cellViewModel.notification.uid ?? ""])
                    case .guestlistAdded:
                        homeViewModel.navigate(to: .close,
                                               withHost: sharedData.hosts[cellViewModel.notification.hostId ?? ""])
                    case .eventPostedWithoutPlanner:
                        homeViewModel.navigate(to: .close,
                                               withEvent: sharedData.events[cellViewModel.notification.eventId ?? ""])
                    default: break
                    }
                } label: {
                    ProfileImageViews(imageUrlsString: cellViewModel.notification.imageUrl)
                }
                .buttonStyle(.borderless)
                
                Group {
                    formattedNotificationMessage
                }
                .multilineTextAlignment(.leading)
                .lineLimit(cellViewModel.notification.count == nil ? 1 : nil)
                .minimumScaleFactor(0.7)
            }
            
            Spacer()
            
            // Side button(s)
            Group {
                switch cellViewModel.notification.type {
                case .friendRequest:
                    HStack(spacing: 15) {
                        ListCellActionButton(text: "checkmark",
                                             isIcon: true) {
                            cellViewModel.acceptFriendRequest()
                        }
                        
                        ListCellActionButton(text: "xmark",
                                             isIcon: true,
                                             isSecondaryLabel: true) {
                            cellViewModel.cancelOrDeleteRelationship()
                        }
                    }
                case .memberInvited:
                    HStack {
                        ListCellActionButton(text: "Join") {
                            cellViewModel.acceptMemberInvite(host: sharedData.hosts[cellViewModel.notification.hostId ?? ""])
                        }
                        
                        ListCellActionButton(text: "Reject",
                                             isSecondaryLabel: true) {
                            cellViewModel.declineMemberInvite()
                        }
                    }
                case .eventLiked, .guestlistAdded:
                    if let event = sharedData.events[cellViewModel.notification.eventId ?? ""] {
                        NotificationSecondaryImage(imageUrl: event.eventImageUrl) {
                            homeViewModel.navigate(to: .close,
                                                   withEvent: sharedData.events[cellViewModel.notification.eventId ?? ""])
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
                        
                        ListCellActionButton(text: "Decline",
                                             isSecondaryLabel: true) {
                            cellViewModel.declinePlannerInvite(event: sharedData.events[cellViewModel.notification.eventId ?? ""])
                        }
                    }
                case .plannerDeclined:
                    ListCellActionButton(text: "Remove") {
                        cellViewModel.removePlanner(event: sharedData.events[cellViewModel.notification.eventId ?? ""])
                    }
                default: Text("")
                }
            }
        }
    }
}

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
            .font(.footnote)
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

        return message + Text(" \(cellViewModel.notification.timestampString)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
