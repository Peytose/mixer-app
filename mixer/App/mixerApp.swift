//
//  mixerApp.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import SwiftUI
import Firebase
import FirebaseDynamicLinks
import AlgoliaSearchClient

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }

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
    @StateObject var authViewModel  = AuthViewModel.shared
    @StateObject var homeViewModel  = HomeViewModel()
    @StateObject var algoliaManager = AlgoliaManager.shared
    @StateObject var linkManager    = UniversalLinkManager.shared
    @Namespace var namespace
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(algoliaManager)
                .environmentObject(linkManager)
                .onOpenURL { url in
                    linkManager.processIncomingURL(url) { event in
                        if let event = event {
                            homeViewModel.pushContext(NavigationContext(state: .close, selectedEvent: event))
                        } else {
                            print("DEBUG: ERROR??")
                        }
                    }
                }
        }
    }
}
