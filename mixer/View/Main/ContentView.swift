//
//  ContentView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Namespace var namespace

//    @State var selectedIndex = 0
    
    var body: some View {
        Group {
            if viewModel.userSession == nil || viewModel.currentUser == nil {
//                AuthFlow()
//                LandingPageView()
                EventInfoView(viewModel: EventDetailViewModel(event: CachedEvent(from: Mockdata.event)), event: CachedEvent(from: Mockdata.event),
                          host: CachedHost(from: Mockdata.host),
                          unsave: {},
                          save: {},
                          coordinates: CLLocationCoordinate2D(latitude: 40, longitude: 50),
                          namespace: namespace)
            } else {
                if let user = viewModel.currentUser {
                    MainTabView(user: user)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
