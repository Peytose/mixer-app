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
    
    var body: some View {
        ZStack(alignment: .center) {
            Group {
                if viewModel.userSession == nil || viewModel.currentUser == nil {
                    AuthFlow()
                } else {
                    if let user = viewModel.currentUser {
                        MainTabView(user: user)
                    }
                }
            }
            
            if viewModel.isLoading {
                LoadingView()
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
