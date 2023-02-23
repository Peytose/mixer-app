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
    @State var isShowingModal = false
    @State private var showingOptions = false
    @State private var showHost = false
    
    init(viewModel: EventDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    EventCoverView(viewModel: viewModel, isShowingModal: $isShowingModal)
                    
                    if let host = viewModel.host {
                        EventInfoView(event: viewModel.event, host: host)
                    }
                }
                .padding(.bottom, 120)
            }
            .background(Color.mixerBackground)
            .coordinateSpace(name: "scroll")
            
            if isShowingModal {
                EventImageModalView(imageUrl: viewModel.event.eventImageUrl, isShowingModal: $isShowingModal)
                    .transition(.scale(scale: 0.01))
                    .zIndex(1)
            }
        }
        .ignoresSafeArea()
        .task { viewModel.fetchEventHost() }
    }
}

fileprivate struct EventImageModalView: View {
    let imageUrl: String
    @Binding var isShowingModal: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .backgroundBlur(radius: 10, opaque: true)
                .ignoresSafeArea()
            
            KFImage(URL(string: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 370, height: 435)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation { isShowingModal = false }
            } label: {
                XDismissButton()
            }
        }
    }
}

fileprivate struct EventCoverView: View {
    @ObservedObject var viewModel: EventDetailViewModel
    @Binding var isShowingModal: Bool
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            VStack {
                ZStack {
                    VStack(alignment: .leading, spacing: 7) {
                        HStack(alignment: .center) {
                            Text(viewModel.event.title)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            
                            Spacer()
                            
                            if viewModel.event.hasStarted == false {
                                if let didSave = viewModel.event.didSave {
                                    Button { didSave ? viewModel.unsave() : viewModel.save() } label: {
                                        Image(systemName: didSave ? "bookmark.fill" : "bookmark")
                                            .resizable()
                                            .scaledToFill()
                                            .foregroundColor(didSave ? Color.mixerPurple : .secondary)
                                            .frame(width: 17, height: 17)
                                            .padding(4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .foregroundColor(.secondary)
                            .padding(.vertical, 5)
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text(viewModel.event.startDate.getTimestampString(format: "EEEE, MMMM d"))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("\(viewModel.event.startDate.getTimestampString(format: "h:mm a")) - \(viewModel.event.endDate.getTimestampString(format: "h:mm a"))")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: viewModel.event.isInviteOnly ? "lock.fill" : "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.secondary)
                                    .frame(width: 22, height: 22)
                                    .background(.ultraThinMaterial)
                                    .backgroundStyle(cornerRadius: 10, opacity: 0.6)
                                    .cornerRadius(10)
                                
                                Text(viewModel.event.isInviteOnly ? "Invite Only" : "Public")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .backgroundStyle(cornerRadius: 30)
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .offset(y: 100)
                    .background {
                        ZStack {
                            KFImage(URL(string: viewModel.event.eventImageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .offset(y: scrollY > 0 ? -scrollY : 0)
                                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                                .blur(radius: scrollY > 0 ? scrollY / 20 : 0)
                                .opacity(0.9)
                                .mask(
                                    RoundedRectangle(cornerRadius: 20)
                                )
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .backgroundBlur(radius: 10, opaque: true)
                                .mask(
                                    RoundedRectangle(cornerRadius: 20)
                                )
                            
                            KFImage(URL(string: viewModel.event.eventImageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .offset(y: scrollY > 0 ? -scrollY : 0)
                                .mask(
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: proxy.size.width - 40, height: proxy.size.height - 50)
                                )
                                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                                .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                                .onLongPressGesture(minimumDuration: 0.3) {
                                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                                    impact.impactOccurred()
                                    withAnimation() {
                                        isShowingModal.toggle()
                                    }
                                }
                                .zIndex(2)
                        }
                    }
                    .offset(y: scrollY > 0 ? -scrollY * 1.8 : 0)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: scrollY > 0 ? 500 + scrollY : 500)  // Change Flyer Height
        }
        .frame(height: 600)
    }
}
