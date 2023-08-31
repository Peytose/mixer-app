//
//  HostDetailView.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import Kingfisher
import CoreLocation
import FirebaseFirestore

struct HostDetailView: View {
    @StateObject private var viewModel: HostViewModel
    var namespace: Namespace.ID?
    @Binding var path: NavigationPath
    @State var showBackArrow = false
    var action: ((NavigationState, Event?, Host?, User?) -> Void)?
    
    init(host: Host, path: Binding<NavigationPath>, action: ((NavigationState, Event?, Host?, User?) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: HostViewModel(host: host))
        self._path      = path
        self.action     = action
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HostBannerView(host: viewModel.host,
                               namespace: namespace)
                .unredacted()
                
                HostInfoView(namespace: namespace,
                             path: $path,
                             viewModel: viewModel,
                             action: action)
            }
            .padding(.bottom, 180)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if path.count > 1 {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationBackArrowButton(path: $path)
                }
            }
        }
        .background(Color.theme.backgroundColor)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}
