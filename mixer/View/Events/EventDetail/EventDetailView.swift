//
//  EventView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/22/23.
//

import SwiftUI
import MapKit
import TabBar
import Kingfisher

struct EventDetailView: View {
    @ObservedObject var viewModel: EventDetailViewModel
    @State var isShowingModal         = false
    @State var showAllAmenities       = false
    @State private var showingOptions = false
    var namespace: Namespace.ID
    
    init(viewModel: EventDetailViewModel, namespace: Namespace.ID) {
        self.viewModel = viewModel
        self.namespace = namespace
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
//                    StretchablePhotoBanner(imageUrl: viewModel.event.eventImageUrl,
//                                           namespace: namespace)
//                        .onLongPressGesture(minimumDuration: 0.3) {
//                            let impact = UIImpactFeedbackGenerator(style: .heavy)
//                            impact.impactOccurred()
//                            withAnimation() {
//                                isShowingModal.toggle()
//                            }
//                        }
                    
//                    if let host = viewModel.host {
//                        EventInfoView(event: viewModel.event,
//                                      host: host,
//                                      unsave: viewModel.unsave,
//                                      save: viewModel.save,
//                                      coordinates: viewModel.coordinates,
//                                      showAllAmenities: $showAllAmenities,
//                                      namespace: namespace)
//                    }
//                    EventInfoView(viewModel: EventDetailViewModel(event: CachedEvent(from: Mockdata.event)), event: CachedEvent(from: Mockdata.event),
//                                  host: CachedHost(from: Mockdata.host),
//                                  unsave: {},
//                                  save: {},
//                                  coordinates: CLLocationCoordinate2D(latitude: 40, longitude: 50),
//                                  namespace: namespace)
                }
                .padding(.bottom, 180)
            }
            .background(Color.mixerBackground)
            .coordinateSpace(name: "scroll")
            
            if isShowingModal {
                EventImageModalView(imageUrl: viewModel.event.eventImageUrl, isShowingModal: $isShowingModal)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showAllAmenities) {
            AmenityListView(amenities: viewModel.event.amenities)
                .presentationDetents([.medium, .large])
        }
    }
}

fileprivate struct EventImageModalView: View {
    let imageUrl: String
    @Binding var isShowingModal: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .backgroundBlur(radius: 10, opaque: true)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isShowingModal = false } }
            
            KFImage(URL(string: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.size.width / 1.2)
                .overlay(alignment: .topTrailing) {
                    Button { withAnimation { isShowingModal = false } } label: { XDismissButton() }
                }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        EventDetailView(viewModel: EventDetailViewModel(event: CachedEvent(from: Mockdata.event)), namespace: namespace)
            .preferredColorScheme(.dark)
    }
}
