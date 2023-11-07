//
//  EventDetailView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/22/23.
//

import SwiftUI
import MapKit
import TabBar
import Kingfisher
import PopupView

struct EventDetailView: View {
    @StateObject private var viewModel: EventViewModel
    var namespace: Namespace.ID?
    @State private var isShowingModal: Bool = false
    @State private var doubleTapLocation: CGPoint = CGPoint.zero
    @State private var showHeart = false
    @State private var heartRotation: Double = 0
    @State private var heartOpacity: Double = 1
    var action: ((NavigationState, Event?, Host?, User?) -> Void)?
    
    init(event: Event, action: ((NavigationState, Event?, Host?, User?) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: EventViewModel(event: event))
        self.action     = action
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack {
                Color.theme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    EventFlyer(imageUrl: $viewModel.event.eventImageUrl,
                               isShowingModal: $isShowingModal)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        EventHeader(viewModel: viewModel)
                        
                        VStack(alignment: .leading) {
                            Text("\(viewModel.event.type.description) hosted by ")
                                .secondaryHeading()
                            
                            ForEach(viewModel.hosts ?? []) { host in
                                if let action = action {
                                    HostSection(host: host)
                                        .onTapGesture {
                                            action(.back, nil, host, nil)
                                        }
                                } else {
                                    NavigationLink {
                                        HostDetailView(host: host)
                                    } label: {
                                        HostSection(host: host)
                                    }
                                }
                            }
                        }
                        
                        EventDetails()
                            .environmentObject(viewModel)
                        
                        if let amenities = viewModel.event.amenities, !amenities.isEmpty {
                            AmenitiesView(amenities: amenities)
                                .environmentObject(viewModel)
                        }
                        
                        LocationSection()
                            .environmentObject(viewModel)
                    }
                    .padding()
                    .padding(.bottom, 120)
                }
                .ignoresSafeArea()
                .onTapGesture(count: 2) { location in
                    let wasFavorited = viewModel.event.isFavorited
                    viewModel.toggleFavoriteStatus()
                    
                    if wasFavorited == false { // If the event was not favorited before and is now favorited
                        self.doubleTapLocation = location
                        self.heartRotation = Double.random(in: 180..<360)
                        self.showHeart = true
                        self.heartOpacity = 1
                        withAnimation(Animation.easeOut(duration: 1.5)) {
                            self.heartOpacity = 0
                        }
                    }
                }
                
                if self.showHeart {
                    HeartView()
                        .rotationEffect(Angle(degrees: self.heartRotation))
                        .opacity(self.heartOpacity)
                        .position(x: doubleTapLocation.x,
                                  y: doubleTapLocation.y - 35) // Adjust the y position to center the heart on the tap
                        .zIndex(1)
                        .id(UUID())
                }
                
                if isShowingModal {
                    EventImageModalView(imageUrl: viewModel.event.eventImageUrl,
                                        isShowingModal: $isShowingModal)
                    .transition(.opacity)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if action == nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        PresentationBackArrowButton()
                    }
                }
            }
            .task {
                if viewModel.event.isFavorited == nil {
                    viewModel.checkIfUserFavoritedEvent()
                }
                
                if viewModel.event.didGuestlist == nil || viewModel.event.didRequest == nil {
                    viewModel.getGuestlistAndRequestStatus()
                }
            }
            .overlay(alignment: .topTrailing) {
                if !viewModel.event.isInviteOnly {
                    GuestlistActionButton(state: EventUserActionState(event: viewModel.event)) {
                        viewModel.actionForState(EventUserActionState(event: viewModel.event))
                    }
                    .padding([.top, .trailing])
                }
            }
            .alert(item: $viewModel.alertItem, content: { $0.alert })
        }
    }
}

struct HeartView: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .foregroundColor(.pink)
            .frame(width: 70, height: 70)
    }
}

struct EventHeader: View {
    @ObservedObject var viewModel: EventViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            HStack {
                Text(viewModel.event.title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)
                
                Spacer()
                
                if let isFavorited = viewModel.event.isFavorited {
                    ParticleEffectButton(systemImage: "heart.fill",
                                         status: isFavorited,
                                         activeTint: .pink,
                                         inActiveTint: .secondary,
                                         frameSize: 45) {
                        viewModel.toggleFavoriteStatus()
                    }
                }
                
                
                if let shareURL = viewModel.shareURL {
                    let event = viewModel.event
                    
                    ShareLink(item: shareURL,
                              message: Text("\nCheck out this event on mixer!"),
                              preview: SharePreview("\(event.title) by \(event.hostNames.joinedWithCommasAndAnd())",
                                                    image: viewModel.imageLoader.image ?? Image("AppIcon")),
                              label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.secondary)
                            .contentShape(Rectangle())
                            .padding()
                    })
                }
            }
            
            Divider()
                .foregroundColor(.secondary)
                .padding(.vertical)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.event.startDate.getTimestampString(format: "EEEE, MMMM d"))
                        .font(.headline)
                    
                    Text("\(viewModel.event.startDate.getTimestampString(format: "h:mm a")) - \(viewModel.event.endDate.getTimestampString(format: "h:mm a"))")
                        .foregroundColor(.secondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: viewModel.event.isInviteOnly ? "lock.fill" : "globe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    
                    Text(viewModel.event.isInviteOnly ? "Private" : "Public")
                        .foregroundColor(.secondary)
                    
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
            .font(.callout.weight(.semibold))
        }
        .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14))
        .background {
            Rectangle()
                .fill(Color.theme.secondaryBackgroundColor)
                .opacity(0.8)
                .cornerRadius(30)
        }
    }
}

struct EventFlyer: View {
    @Binding var imageUrl: String
    @Binding var isShowingModal: Bool
    
    var body: some View {
        StretchablePhotoBanner(imageUrl: imageUrl)
            .onLongPressGesture(minimumDuration: 0.1) {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                withAnimation() {
                    isShowingModal.toggle()
                }
            }
    }
}

struct HostSection: View {
    var host: Host
    
    var body: some View {
            HStack(spacing: 12) {
                KFImage(URL(string: host.hostImageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                
                HStack {
                    Text("\(host.name)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color.theme.mixerIndigo)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    //MARK: WILL UPDATE SOON! (PEYTON)
//                    if let isFollowed = host.isFollowed {
//                        Button {
//                            withAnimation(.follow) {
//                                viewModel.updateFollow(isFollowed)
//                            }
//                        } label: {
//                            Text(isFollowed ? "Following" : "Follow")
//                                .font(.footnote)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.white)
//                                .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
//                                .background {
//                                    Capsule()
//                                        .stroke(lineWidth: 1)
//                                }
//                        }
//                        .buttonStyle(.plain)
//                    }
                }
            }
    }
}

struct EventDetails: View {
    @EnvironmentObject var viewModel: EventViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .primaryHeading()
                
                Text(viewModel.event.description)
                    .foregroundColor(.secondary)
            }
            
            if let note = viewModel.event.note {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes for guest")
                        .primaryHeading()
                    
                    Text(note)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Event details")
                    .primaryHeading()
                
                HStack {
                    if let amenities = viewModel.event.amenities {
                        if amenities.contains(where: { $0.rawValue.contains("Beer") || $0.rawValue.contains("Alcoholic Drinks") }) {
                            DetailRow(text: "Wet Event",
                                      icon: "drop.fill")
                        } else {
                            DetailRow(text: "Dry Event",
                                      icon: "drop.fill")
                        }
                    }
                    
                    InfoButton { viewModel.alertItem = AlertContext.wetAndDryEventsInfo }
                }
                
                HStack {
                    if viewModel.event.isInviteOnly {
                        DetailRow(text: "Invite Only Event",
                                  icon: "list.clipboard.fill")
                    } else {
                        DetailRow(text: "Open Event",
                                  icon: "list.clipboard.fill")
                    }
                    
                    InfoButton { viewModel.alertItem = AlertContext.openAndInviteOnlyEventsInfo }
                }
            }
        }
    }
}

struct AmenitiesView: View {
    let amenities: [EventAmenity]
    @State private var showAllAmenities = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What this event offers")
                .primaryHeading()
            
            ForEach(showAllAmenities ? AmenityCategory.allCases : Array(AmenityCategory.allCases.prefix(1)), id: \.self) { category in
                let amenitiesInCategory = amenities.filter({ $0.category == category })
                if !amenitiesInCategory.isEmpty {
                    Section {
                        ForEach(amenitiesInCategory, id: \.self) { amenity in
                            HStack {
                                amenity.displayIcon
                                    .font(.body)
                                    .padding(.trailing, 5)
                                
                                Text(amenity.rawValue)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .foregroundColor(.white)
                        }
                    } header: {
                        Text(category.rawValue)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                            .padding(.bottom, 2)
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Button {
                    withAnimation(.spring(dampingFraction: 0.8)) {
                        showAllAmenities.toggle()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.white)
                            .frame(width: 350, height: 45)
                            .overlay {
                                Text(showAllAmenities ? "Show less" : "Show all \(amenities.count) amenities")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                            }
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct LocationSection: View {
    @EnvironmentObject var viewModel: EventViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Where you'll be")
                    .primaryHeading(color: .white)
                
                InfoButton { viewModel.alertItem = AlertContext.locationDetailsInfo }
            }
            
            if viewModel.event.isInviteOnly && !(viewModel.event.didGuestlist ?? false) {
                if let altAddress = viewModel.event.altAddress {
                    DetailRow(text: altAddress,
                              icon: "mappin.and.ellipse")
                } else {
                    DetailRow(text: "Available when you are on the guestlist",
                              icon: "mappin.and.ellipse")
                }
            } else {
                let location = CLLocationCoordinate2D(latitude: viewModel.event.geoPoint.latitude,
                                                      longitude: viewModel.event.geoPoint.longitude)
                VStack(alignment: .leading, spacing: 5) {
                    MapSnapshotView(location: .constant(location))
                        .onTapGesture { /* Add code to get directions to location */ }
                    
                    Text("Tap the map for directions to this event!")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
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
        }
    }
}

fileprivate struct GuestlistActionButton: View {
    let state: EventUserActionState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: state.icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                
                Text(state.eventDetailText)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundColor(state.isSecondaryLabel ? .secondary : .white)
            .padding()
            .background {
                Capsule()
                    .fill (
                        (state.isSecondaryLabel ? Color.theme.secondaryBackgroundColor : Color.theme.mixerIndigo)
                            .opacity(0.7)
                    )
                    .clipShape(Capsule())
                    .shadow(radius: 2)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: dev.mockEvent)
    }
}
