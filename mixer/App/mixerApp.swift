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
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {
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
    @StateObject private var dataController = DataController()
    @StateObject var authViewModel  = AuthViewModel.shared
    @StateObject var homeViewModel  = HomeViewModel()
    @StateObject var algoliaManager = AlgoliaManager.shared
    @StateObject var linkManager    = UniversalLinkManager.shared
    @Namespace var namespace
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .preferredColorScheme(.dark)
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(algoliaManager)
                .environmentObject(linkManager)
                .onOpenURL { url in
                    linkManager.processIncomingURL(url) { model in
                        DispatchQueue.main.async {
                            if let event = model as? Event {
                                homeViewModel.pushContext(NavigationContext(state: .close,
                                                                            selectedEvent: event))
                            } else if let host = model as? Host {
                                homeViewModel.pushContext(NavigationContext(state: .close,
                                                                            selectedHost: host))
                            } else if let user = model as? User {
                                homeViewModel.pushContext(NavigationContext(state: .close,
                                                                            selectedUser: user))
                            } else {
                                // ERROR: Handle unknown model type
                                print("DEBUG: Unknown model type received from URL.")
                            }
                        }
                    }
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var viewModel = MapViewModel()
    static var dataController = DataController()
    static var authViewModel  = AuthViewModel.shared
    static var homeViewModel  = HomeViewModel()
    static var algoliaManager = AlgoliaManager.shared
    static var linkManager    = UniversalLinkManager.shared
    
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .preferredColorScheme(.dark)
            .environmentObject(authViewModel)
            .environmentObject(homeViewModel)
            .environmentObject(algoliaManager)
            .environmentObject(linkManager)
    }
}

