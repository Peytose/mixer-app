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
    @EnvironmentObject var viewModel: EventViewModel
    var namespace: Namespace.ID?
    @State private var isShowingModal = false
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                EventFlyerHeader(isShowingModal: $isShowingModal)
                
                VStack(alignment: .leading, spacing: 20) {
                    HostSection()
                    
                    EventDetails()
                    
                    if let amenities = viewModel.event.amenities {
                        AmenitiesView(amenities: amenities)
                    }
                    
                    LocationSection()
                }
                .padding()
                .padding(EdgeInsets(top: 100, leading: 0, bottom: 120, trailing: 0))
            }
            .coordinateSpace(name: "scroll")
            
            if isShowingModal {
                EventImageModalView(imageUrl: viewModel.event.eventImageUrl, isShowingModal: $isShowingModal)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            viewModel.checkIfUserFavoritedEvent()
            viewModel.checkIfUserIsOnGuestlist()
        }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
    }
}

struct EventDetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        EventDetailView(namespace: namespace)
            .environmentObject(EventViewModel(event: dev.mockEvent))
    }
}

struct EventFlyerHeader: View {
    @EnvironmentObject var viewModel: EventViewModel
    @Binding var isShowingModal: Bool
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            VStack {
                ZStack {
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
                                CustomButton(systemImage: "heart.fill",
                                             status: isFavorited,
                                             activeTint: .pink,
                                             inActiveTint: .secondary) {
                                    viewModel.updateFavorite()
                                }
                            }
                            
                            if let eventId = viewModel.event.id,
                               let url = URL(string: "https://mixer.page.link/event?eventId=\(eventId)") {
                                ShareLink(item: url,
                                          message: Text("\nCheck out this event on mixer!"),
                                          preview: SharePreview("\(viewModel.event.title) by \(viewModel.event.hostName)",
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
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .backgroundStyle(cornerRadius: 30)
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .offset(y: 120)
                    .background(
                        ZStack {
                            KFImage(URL(string: viewModel.event.eventImageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 550)
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
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(20)
                                .frame(width: proxy.size.width - 60, height: proxy.size.height - 60)
                                .mask(
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: proxy.size.width - 50, height: proxy.size.height - 50)
                                )
                                .offset(y: scrollY > 0 ? -scrollY : 0)
                                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                                .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                                .scaleEffect(finalAmount + currentAmount)
                                .onLongPressGesture(minimumDuration: 0.1) {
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
            .frame(height: scrollY > 0 ? 500 + scrollY : 500)
        }
        .frame(height: 500)
    }
}

struct HostSection: View {
    @EnvironmentObject var viewModel: EventViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var hostManager: HostManager
    
    var body: some View {
        if let host = viewModel.host {
            HStack(spacing: 12) {
                KFImage(URL(string: host.hostImageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(viewModel.event.type.description) hosted by ")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("\(host.name)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.theme.mixerIndigo)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    Spacer()
                    
                    if let isFollowed = host.isFollowed {
                        Button {
                            withAnimation(.follow) {
                                viewModel.updateFollow(isFollowed)
                            }
                        } label: {
                            Text(isFollowed ? "Following" : "Follow")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
                                .background {
                                    Capsule()
                                        .stroke(lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .onTapGesture {
                homeViewModel.handleTap(to: .embeddedHostDetailView,
                                        host: host,
                                        hostManager: hostManager)
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
                            DetailRow(image: "drop.fill", text: "Wet Event")
                        } else {
                            DetailRow(image: "drop.fill", text: "Dry Event")
                        }
                    }
                    
                    InfoButton { viewModel.alertItem = AlertContext.wetAndDryEventsInfo }
                }
                
                HStack {
                    if viewModel.event.isInviteOnly {
                        DetailRow(image: "list.clipboard.fill", text: "Invite Only Event")
                    } else {
                        DetailRow(image: "list.clipboard.fill", text: "Open Event")
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
            
            if viewModel.event.isInviteOnly && (viewModel.event.didGuestlist ?? false) {
                if let altAddress = viewModel.event.altAddress {
                    DetailRow(image: "mappin.and.ellipse", text: altAddress)
                } else {
                    DetailRow(image: "mappin.and.ellipse", text: "Available when you are on the guest list")
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

fileprivate struct JoinGuestlistButton: View {
    let action: () -> Void
    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            action()
        } label: {
            HStack {
                Image(systemName: "list.clipboard")
                    .imageScale(.large)
                
                Text("Join Guestlist")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .background {
                Capsule()
                    .fill(Color.theme.mixerPurpleGradient)
            }
        }
    }
}


@ViewBuilder
func CustomButton(systemImage: String, status: Bool, activeTint: Color, inActiveTint: Color, onTap: @escaping () -> ()) -> some View {
    Button(action: onTap) {
        Image(systemName: systemImage)
            .font(.title2)
            .particleEffect(
                systemImage: systemImage,
                font: .body,
                status: status,
                activeTint: activeTint,
                inActiveTint: inActiveTint
            )
            .foregroundColor(status ? activeTint : inActiveTint)
    }
}
