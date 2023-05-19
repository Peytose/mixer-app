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
    @ObservedObject var viewModel: HostDetailViewModel
    var namespace: Namespace.ID
    @State var showUsername = false
    
    init(viewModel: HostDetailViewModel, namespace: Namespace.ID) {
        self.viewModel = viewModel
        self.namespace = namespace
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    HostBannerView(host: viewModel.host, namespace: namespace)
                        .unredacted()
                    
                    HostInfoView(namespace: namespace,
                                 viewModel: viewModel)
                }
                .padding(.bottom, 180)
                .redacted(reason: viewModel.isLoading ? .placeholder : [])
            }
        }
        .background(Color.mixerBackground)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}

struct HostDetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        HostDetailView(viewModel: HostDetailViewModel(host: CachedHost(from: Mockdata.host)), namespace: namespace)
    }
}
