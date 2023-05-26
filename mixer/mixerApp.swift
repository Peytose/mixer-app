//
//  mixerApp.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import SwiftUI
import Firebase
import FirebaseDynamicLinks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Colors application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\(#function)")
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(#function)")
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
}

@main
struct mixerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var dynamicLinkManager = DynamicLinkManager.shared
    @StateObject var authViewModel = AuthViewModel.shared
    @Namespace var namespace
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(authViewModel)
                .environmentObject(dynamicLinkManager)
                .fullScreenCover(item: $dynamicLinkManager.profileToPresent) { user in
                    ProfileView(viewModel: ProfileViewModel(user: user))
                        .zIndex(0)
                }
                .fullScreenCover(item: $dynamicLinkManager.eventToPresent) { event in
                    EventDetailView(viewModel: EventDetailViewModel(event: event), namespace: namespace)
                        .zIndex(0)
                }
                .onOpenURL { url in
                    print("DEBUG: Handling URL...")
                    
                    // First, try to handle this URL as a Firebase Authentication redirect
                    if Auth.auth().canHandle(url) {
                        print("DEBUG: URL handled as Firebase Auth redirect.")
                        authViewModel.next()
                    } else if url.path.contains("profile") {
                        print("DEBUG: Dynamic link contained 'profile'!")
                        
                        // Handle the dynamic link for a profile
                        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                           let queryItems = components.queryItems,
                           let uidItem = queryItems.first(where: { $0.name == "uid" }) {
                            let uid = uidItem.value
                            Task {
                                do {
                                    if let uid = uid {
                                        DynamicLinkManager.shared.profileToPresent = try await UserCache.shared.getUser(withId: uid)
                                        print("DEBUG: Uid from dynamic link: \(uid)")
                                    }
                                } catch {
                                    print("DEBUG: Error getting profile from share link. \(error.localizedDescription)")
                                }
                            }
                        }
                    } else if url.path.contains("event") {
                        print("DEBUG: Dynamic link contained 'event'!")
                        
                        // Handle the dynamic link for an event
                        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                           let queryItems = components.queryItems,
                           let eventIdItem = queryItems.first(where: { $0.name == "eventId" }) {
                            let eventId = eventIdItem.value
                            Task {
                                do {
                                    if let eventId = eventId {
                                        DynamicLinkManager.shared.eventToPresent = try await EventCache.shared.getEvent(from: eventId)
                                        print("DEBUG: Event ID from dynamic link: \(eventId)")
                                    }
                                } catch {
                                    print("DEBUG: Error getting event from share link. \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
        }
    }
}
