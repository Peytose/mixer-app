//
//  ContentView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
//        Group {
//            if viewModel.userSession != nil, let user = viewModel.currentUser {
//                MainTabView(user: user)
//            } else {
//                AuthFlow()
//            }
//        }
        MainTabView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(Model())
    }
}
