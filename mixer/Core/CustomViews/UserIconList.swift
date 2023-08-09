//
//  UserIconList.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import Kingfisher

enum UserIconListText: String {
    case follow
    case friend
    case interested
    case going
    
    func getText(users: [User]) -> String {
        switch users.count {
        case 0:
            return ""
        case 1:
            switch self {
            case .follow:
                return "Followed by " + users[0].username
            case .friend:
                return "Friends with " + users[0].username
            case .interested:
                return users[0].username + " is also interested"
            case .going:
                return users[0].username + " is also going"
            }
        case 2:
            let names = users.map { $0.username }.joined(separator: " and ")
            switch self {
            case .follow:
                return "Followed by " + names
            case .friend:
                return "Friends with " + names
            case .interested:
                return names + " are also interested"
            case .going:
                return names + " are also going"
            }
        default:
            let names = users.prefix(2).map { $0.username }.joined(separator: ", ")
            let count = users.count - 2
            switch self {
            case .follow:
                return "Followed by " + names + ", and \(count) more"
            case .friend:
                return "Friends with " + names + ", and \(count) more"
            case .interested:
                return names + ", and \(count) more are also interested"
            case .going:
                return names + ", and \(count) more are also going"
            }
        }
    }
}

struct UserIconList: View {
    let users: [User]
    var text: UserIconListText = .friend
    
    var body: some View {
        HStack {
            HStack(spacing: -8) {
                ForEach(Array(zip(users.indices, users)), id: \.0) { index, user in
                    if index < 2 {
                        Circle()
                            .stroke()
                            .foregroundColor(Color.theme.secondaryBackgroundColor)
                            .frame(width: 28, height: 46)
                            .overlay {
                                if users.count > 2 {
                                    Text(users.count < 99 ? "\(users.count - 2)" : "99+")
                                        .foregroundColor(.white)
                                        .font(.footnote)
                                } else {
                                    KFImage(URL(string: user.profileImageUrl))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                }
                            }
                    }
                }
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 3) {
                    Text(text.getText(users: users))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
        }
    }
}

struct UserIconList_Previews: PreviewProvider {
    static var previews: some View {
        UserIconList(users: [dev.mockUser])
            .preferredColorScheme(.dark)
    }
}
