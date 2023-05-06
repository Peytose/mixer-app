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
//    @State var isFollowing  = false
    @State var showUsername = false
    
    init(viewModel: HostDetailViewModel, namespace: Namespace.ID) {
        self.viewModel = viewModel
        self.namespace = namespace
    }
    
    var body: some View {
        ZStack(alignment: .center ) {
            ScrollView(showsIndicators: false) {
                VStack {
                    HostBannerView(host: viewModel.host, namespace: namespace)
                    
                    HostInfoView(host: viewModel.host,
                                 coordinates: viewModel.coordinates,
                                 namespace: namespace,
                                 viewModel: viewModel)
                }
                .padding(.bottom, 180)
            }
            
            if viewModel.isLoading { LoadingView() }
        }
        .background(Color.mixerBackground)
        .coordinateSpace(name: "scroll")
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

struct HostSubheading: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.title)
            .bold()
            .foregroundColor(.white)
    }
}

struct RecentEventRow: View {
    let imageUrl: String
    let title: String
    let date: String
    let attendance: Int?
    
    var body: some View {
        HStack(spacing: 15) {
            KFImage(URL(string: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                
                
                HStack {
                    Text(date)
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.secondary)
                    
                    if let attendance = attendance {
                        HStack(spacing: 2) {
                            Image(systemName: "person.3.fill")
                                .imageScale(.small)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("\(attendance)")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            
            Spacer()
        }
        .frame(height: 60)
    }
}
