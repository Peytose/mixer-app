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
                .fullScreenCover(item: $dynamicLinkManager.itemToPresent) { item in
                    item.view(using: namespace)
                        .zIndex(0)
                }
                .onOpenURL { url in
                    print("DEBUG: Handling URL...")
                    
                    // First, try to handle this URL as a Firebase Authentication redirect
                    if Auth.auth().canHandle(url) {
                        print("DEBUG: URL handled as Firebase Auth redirect.")
                        authViewModel.next()
                    } else {
                        // Handle the link using DynamicLinkManager
                        dynamicLinkManager.handleLink(url: url)
                    }
                }
        }
    }
}
