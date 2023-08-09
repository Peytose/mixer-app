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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }

        // Handle other URLs if needed
        return false
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
    @StateObject var authViewModel = AuthViewModel.shared
    @StateObject var homeViewModel = HomeViewModel()
    @Namespace var namespace
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
        }
    }
}




// MARK: - For later implementation..
//    .fullScreenCover(item: $dynamicLinkManager.itemToPresent) { item in
//        item.view(using: namespace)
//            .zIndex(0)
//    }
//    .onOpenURL { url in
//        print("DEBUG: Handling URL...")
//
//        // First, try to handle this URL as a Firebase Authentication redirect
//        if Auth.auth().canHandle(url) {
//            print("DEBUG: URL handled as Firebase Auth redirect.")
//            authViewModel.next()
//        } else {
//            // Handle the link using DynamicLinkManager
//            dynamicLinkManager.handleLink(url: url)
//        }
//    }
