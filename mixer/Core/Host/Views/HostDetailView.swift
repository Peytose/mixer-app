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
    @EnvironmentObject var viewModel: HostViewModel
    var namespace: Namespace.ID
    
    init(namespace: Namespace.ID) {
        self.namespace = namespace
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HostBannerView(host: viewModel.host,
                               namespace: namespace)
                    .unredacted()
                
                HostInfoView(namespace: namespace)
            }
            .padding(.bottom, 180)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackArrowButton()
            }
        }
        .background(Color.theme.backgroundColor)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}

struct HostDetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        HostDetailView(namespace: namespace)
            .environmentObject(HostViewModel(host: dev.mockHost))
    }
}
