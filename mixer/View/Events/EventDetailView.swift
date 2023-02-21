//
//  EventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
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
                EventCoverView(viewModel: viewModel, isShowingModal: $isShowingModal)
                
                if let host = viewModel.host {
                    EventInfoView(event: viewModel.event, host: host)
                }
            }
            .background(Color.mixerBackground)
            .coordinateSpace(name: "scroll")
            
            if isShowingModal {
                EventImageModalView(imageUrl: viewModel.event.eventImageUrl, isShowingModal: $isShowingModal)
                    .transition(.scale(scale: 0.01))
                    .zIndex(1)
            }
        }
        .task {
            viewModel.fetchEventHost()
        }
    }
}

fileprivate struct PaddedImage: View {
    let image: String
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 21, height: 21)
                .padding(8)
                .background(.ultraThinMaterial)
                .backgroundStyle(cornerRadius: 10, opacity: 0.6)
            
        }
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

fileprivate struct EventInfoView: View {
    let event: CachedEvent
    let host: CachedHost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HostedBySection(type: event.type,
                            name: host.name,
                            imageUrl: host.hostImageUrl,
                            ageLimit: event.ageLimit,
                            cost: event.cost,
                            hasAlcohol: event.alcoholPresence)
            
            Divider()
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("What this event offers")
                    .font(.title2)
                    .bold()
                
                ForEach(event.amenities.shuffled().prefix(upTo: 4), id: \.self) { amenity in
                    HStack {
                        Image(systemName: amenity.icon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 15, height: 15)
                        
                        Text(amenity.rawValue)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                
                HStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.DesignCodeWhite)
                            .frame(width: 350, height: 45)
                        
                        Text("Show all \(event.amenities.count) amenities")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
            }
            
            Divider()
            
            Text("Where you'll be")
                .font(.title2)
                .bold()
            
            //            MapSnapshotView(location: coordinates)
            //                .cornerRadius(12)
        }
        .padding(.horizontal)
        .frame(maxHeight: UIScreen.main.bounds.size.height)
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
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(viewModel.event.title)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)
                                
                                Spacer()
                            }
                            
                            HStack {
                                if let host = viewModel.host {
                                    NavigationLink(destination: HostDetailView(viewModel: HostDetailViewModel(host: host))) {
                                        HStack {
                                            KFImage(URL(string: host.hostImageUrl))
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 25, height: 25)
                                            
                                            Text(host.name)
                                                .font(.body)
                                                .foregroundColor(.primary.opacity(0.7))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.75)
                                        }
                                    }
                                }
                                
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
                        }
                        
                        Divider()
                            .foregroundColor(.secondary)
                        
                        HeadingBottomRowView(date: viewModel.event.startDate.getTimestampString(format: "EEEE, MMMM d"),
                                             startTime: viewModel.event.startDate.getTimestampString(format: "h:mm a"),
                                             endTime: viewModel.event.startDate.getTimestampString(format: "h:mm a"),
                                             alcohol: viewModel.event.alcoholPresence)
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
                    .background(
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
                    )
                    .offset(y: scrollY > 0 ? -scrollY * 1.8 : 0)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: scrollY > 0 ? 500 + scrollY : 500)  //MARK: Change Flyer Height
        }
        .frame(height: 500)
    }
}

struct EventInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EventInfoView(event: CachedEvent(from: Mockdata.event), host: CachedHost(from: Mockdata.host))
            .preferredColorScheme(.dark)
    }
}

fileprivate struct HeadingBottomRowView: View {
    let date: String
    let startTime: String
    let endTime: String
    let alcohol: Bool?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(date)
                    .font(.title3.weight(.semibold))
                
                Text("\(startTime) - \(endTime)")
                    .foregroundColor(.secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            
            Spacer()
            
            VStack(alignment: .center, spacing: 4) {
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .background(.ultraThinMaterial)
                    .backgroundStyle(cornerRadius: 10, opacity: 0.6)
                    .cornerRadius(10)
                
                if let alcohol = alcohol {
                    Text("\(alcohol ? "Wet" : "Dry") Event")
                        .foregroundColor(.secondary)
                }
            }
        }
        .font(.headline)
    }
}

fileprivate struct HostedBySection: View {
    let type: EventType
    let name: String
    let imageUrl: String
    var ageLimit: Int?
    var cost: Float?
    var hasAlcohol: Bool?
    let dot: Text = Text("•").font(.callout).foregroundColor(.secondary)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(type.eventStringSing) by \(name)")
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                HStack {
                    if let ageLimit = ageLimit {
                        Text("\(ageLimit)+")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if cost != nil || hasAlcohol != nil { dot }
                    }
                    
                    if let cost = cost {
                        Text("$\(cost.roundToDigits(2))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if hasAlcohol != nil { dot }
                    }
                    
                    if let hasAlcohol = hasAlcohol {
                        Text("\(hasAlcohol ? "Wet" : "Dry") event")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 63, height: 63)
        }
    }
}
