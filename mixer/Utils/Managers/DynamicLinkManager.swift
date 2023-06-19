//
//  DynamicLinkManager.swift
//  mixer
//
//  Created by Peyton Lyons on 5/19/23.
//

import SwiftUI
import FirebaseDynamicLinks

enum DisplayItem: Identifiable {
    case user(CachedUser)
    case event(CachedEvent)
    case host(CachedHost)
    
    var id: String {
        switch self {
        case .user(let user):
            return user.id ?? user.name
        case .event(let event):
            return event.id ?? event.title
        case .host(let host):
            return host.id ?? host.name
        }
    }
    
    @ViewBuilder
    func view(using namespace: Namespace.ID) -> some View {
        switch self {
        case .user(let user):
            ProfileView(viewModel: ProfileViewModel(user: user))
        case .event(let event):
            EventDetailView(viewModel: EventDetailViewModel(event: event), namespace: namespace)
        case .host(let host):
            HostDetailView(viewModel: HostDetailViewModel(host: host), namespace: namespace)
        }
    }
}

class DynamicLinkManager: ObservableObject {
    static let shared = DynamicLinkManager()
    @Published var itemToPresent: DisplayItem? = nil
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("No URL found in dynamic link")
            return
        }
        handleLink(url: url)
    }

    func handleLink(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let pathComponents = components?.path.split(separator: "/") else {
            print("Invalid URL format for dynamic link")
            return
        }

        guard let uidItem = components?.queryItems?.first(where: { $0.name == "uid" }),
              let uid = uidItem.value else {
            print("Invalid URL format for dynamic link")
            return
        }

        Task {
            switch pathComponents[0] {
            case "profile":
                await fetchItem(with: uid,
                                    fetchFunction: UserCache.shared.getUser,
                                    displayFunction: DisplayItem.user)
            case "event":
                await fetchItem(with: uid,
                                    fetchFunction: EventCache.shared.getEvent,
                                    displayFunction: DisplayItem.event)
            case "host":
                await fetchItem(with: uid,
                                    fetchFunction: HostCache.shared.getHost,
                                    displayFunction: DisplayItem.host)
            default:
                print("Unknown dynamic link")
            }
        }
    }
    
    private func fetchItem<T>(with id: String, fetchFunction: @escaping (String) async throws -> T, displayFunction: @escaping (T) -> DisplayItem) async {
        do {
            let item = try await fetchFunction(id)
            DispatchQueue.main.async {
                DynamicLinkManager.shared.itemToPresent = displayFunction(item)
            }
            print("DEBUG: ID from dynamic link: \(id)")
        } catch {
            print("DEBUG: Error getting item from share link. \(error.localizedDescription)")
        }
    }
}
