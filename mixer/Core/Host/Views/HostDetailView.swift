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
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: HostViewModel
    var namespace: Namespace.ID
    
    @State var showBackArrow = false
    var action: ((NavigationState, Event?, Host?, User?) -> Void)?
    
    init(host: Host, action: ((NavigationState, Event?, Host?, User?) -> Void)? = nil, namespace: Namespace.ID) {
        self._viewModel = StateObject(wrappedValue: HostViewModel(host: host))
        self.action     = action
        self.namespace  = namespace
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HostBannerView(host: viewModel.host,
                               namespace: namespace)
                .unredacted()
                
                HostInfoView(namespace: namespace,
                             viewModel: viewModel,
                             action: action)
            }
            .padding(.bottom, 180)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if action == nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    PresentationBackArrowButton()
                }
            }
        }
        .background(Color.theme.backgroundColor)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}
