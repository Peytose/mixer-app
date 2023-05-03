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
                    LaunchPageView()
                } else {
                    if let user = viewModel.currentUser {
                        MainTabView(user: user)
                    }
                }
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
            
            LaunchScreenView()
                .autoDismissView(duration: 1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}

struct AutoDismissView: ViewModifier {
    let duration: TimeInterval
    
    @State private var show = true
    
    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        self.show = false
                    }
                }
            }
    }
}

extension View {
    func autoDismissView(duration: TimeInterval) -> some View {
        self.modifier(AutoDismissView(duration: duration))
    }
}
