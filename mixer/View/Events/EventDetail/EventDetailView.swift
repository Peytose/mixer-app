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
    @ObservedObject var viewModel: EventDetailViewModel
    @State private var isShowingModal   = false
    @State private var currentAmount    = 0.0
    @State private var finalAmount      = 1.0
    @State private var showHost         = false
    @State private var showAllAmenities = false
    @State var showInfoAlert1           = false
    @State var showInfoAlert2           = false
    @State var showInfoAlert3           = false
    @State var isLiked                  = false
    @State var addedEvent               = false
    @State var removedEvent             = false
    @Environment(\.presentationMode) var presentationMode
    
    var namespace: Namespace.ID
    
    init(viewModel: EventDetailViewModel, namespace: Namespace.ID) {
        self.viewModel = viewModel
        self.namespace = namespace
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                EventFlyerHeader
                
                VStack(alignment: .leading, spacing: 20) {
                    HostedBySection(viewModel: viewModel,
                                    namespace: namespace)
                    .onTapGesture {
                        showHost.toggle()
                    }
                    
                    content
                    
                    if let amenities = viewModel.event.amenities {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What this event offers")
                                    .primaryHeading()
                                
                                //MARK: ERROR: Amenities outside first category don't display.
                                ForEach(showAllAmenities ? AmenityCategory.allCases : Array(AmenityCategory.allCases.prefix(1)), id: \.self) { category in
                                    let amenitiesInCategory = amenities.filter({ $0.category == category })
                                    if !amenitiesInCategory.isEmpty {
                                        Section(header: Text(category.rawValue).font(.title3.weight(.semibold)).padding(.top, 10).padding(.bottom, 2)) {
                                            ForEach(amenitiesInCategory, id: \.self) { amenity in
                                                HStack {
                                                    if amenity == .beer {
                                                        Text("🍺")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else if amenity == .water {
                                                        Text("💦")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else if amenity == .smokingArea {
                                                        Text("🚬")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else if amenity == .dj {
                                                        Text("🎧")
                                                    } else if amenity == .coatCheck {
                                                        Text("🧥")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else if amenity == .nonAlcohol {
                                                        Text("🧃")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else if amenity == .food {
                                                        Text("🍕")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else if amenity == .danceFloor {
                                                        Text("🕺")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else if amenity == .snacks {
                                                        Text("🍪")
                                                    } else if amenity == . drinkingGames{
                                                        Text("🏓")
                                                            .font(.system(size: 15))
                                                            .padding(.trailing, 5)
                                                    } else {
                                                        Image(systemName: amenity.icon)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 15, height: 15)
                                                            .padding(.trailing, 5)
                                                    }
                                                    
                                                    Text(amenity.rawValue)
                                                        .font(.body)
                                                    
                                                    Spacer()
                                                }
                                                .foregroundColor(.white)
                                            }
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
                                                .foregroundColor(.DesignCodeWhite)
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Where you'll be")
                                .primaryHeading(color: .white)
                            
                            InfoButton(action: { showInfoAlert2.toggle() })
                                .alert("Location Details", isPresented: $showInfoAlert2, actions: {}, message: {Text("For invite only parties that you have not been invited, you can only see the general location. Once you are on the guest list, you will be able to see the exact location")})
                        }
                        
                        if viewModel.event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false {
                            if let publicAddress = viewModel.event.publicAddress {
                                DetailRow(image: "mappin.and.ellipse", text: publicAddress)
                            } else if let coords = viewModel.coordinates {
                                VStack(alignment: .leading, spacing: 5) {
                                    MapSnapshotView(location: coords, event: viewModel.event)
                                        .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coords) }
                                    
                                    Text("Tap the map for directions to this event!")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                DetailRow(image: "mappin.and.ellipse", text: "Available when you are on the guest list")
                            }
                        } else {
                            if let coords = viewModel.coordinates {
                                VStack(alignment: .leading, spacing: 4) {
                                    MapSnapshotView(location: coords, event: viewModel.event)
                                        .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coords) }
                                    
                                    Text("Tap the map for directions to this event!")
                                        .footnote()
                                }
                            }
                        }
                    }
                }
                .padding()
                .padding(EdgeInsets(top: 100, leading: 0, bottom: 120, trailing: 0))
            }
            .background(Color.mixerBackground)
            .coordinateSpace(name: "scroll")
            
            if isShowingModal {
                EventImageModalView(imageUrl: viewModel.event.eventImageUrl, isShowingModal: $isShowingModal)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                BackArrowButton()
            })
            .padding(.horizontal)
            .padding(.top, 70)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
        .sheet(isPresented: $showHost) {
            if let host = viewModel.host {
                HostDetailView(viewModel: HostDetailViewModel(host: host), namespace: namespace)
            }
        }
        .popup(isPresented: $addedEvent) {
            LikedEventNotification(title: viewModel.event.title, text: "has been added to your liked events")
        } customize: {
            $0
                .type(.floater(verticalPadding: 50, useSafeAreaInset: true))
                .position(.top)
                .animation(.spring())
                .autohideIn(2)
        }
        .popup(isPresented: $removedEvent) {
            LikedEventNotification(title: viewModel.event.title, text: "has been removed from your liked events")
        } customize: {
            $0
                .type(.floater(verticalPadding: 50, useSafeAreaInset: true))
                .position(.top)
                .animation(.spring())
                .autohideIn(2)
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .primaryHeading()
                
                Text(viewModel.event.description)
                    .foregroundColor(.secondary)
            }
            
            if let notes = viewModel.event.notes {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes for guest")
                        .primaryHeading()
                    
                    Text(notes)
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
                    
                    InfoButton(action: { showInfoAlert1.toggle() })
                        .alert("Wet and Dry Events", isPresented: $showInfoAlert1, actions: {}, message: {Text("Wet events offer beer/alcohol. Dry events do not offer alcohol.")})
                }
                
                HStack {
                    if viewModel.event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false {
                        DetailRow(image: "list.clipboard.fill", text: "Invite Only Event")
                    } else {
                        DetailRow(image: "list.clipboard.fill", text: "Open Event")
                    }
                    
                    InfoButton(action: { showInfoAlert3.toggle() })
                        .alert("Open and Invite Only Events", isPresented: $showInfoAlert3, actions: {}, message: {Text("You can only see the exact location and start time of an Invite Only Event if you are on its guestlist. On the other hand, you can always see all the details of an Open Event")})
                }
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        EventDetailView(viewModel: EventDetailViewModel(event: CachedEvent(from: Mockdata.event)),
                        namespace: namespace)
            .preferredColorScheme(.dark)
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

fileprivate struct HostedBySection: View {
    @ObservedObject var viewModel: EventDetailViewModel
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 12) {
            if let host = viewModel.host {
                KFImage(URL(string: host.hostImageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(viewModel.event.type.rawValue) hosted by ")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                            
                            Text("\(host.name)")
                                .font(.title3)
                                .bold()
                                .foregroundColor(Color.mixerIndigo)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer()
                        
                        if var isFollowed = host.isFollowed {
                            Button {
                                withAnimation(.follow) {
                                    isFollowed ? viewModel.unfollowHost() : viewModel.followHost()
                                    isFollowed.toggle()
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
                                            .matchedGeometryEffect(id: "eventFollowButton-\(viewModel.event.id ?? "")",
                                                                   in: namespace)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
            }
        }
    }
}

extension EventDetailView {
    var EventFlyerHeader: some View {
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
                            
                            CustomButton(systemImage: "heart.fill",
                                         status: viewModel.event.didLike ?? false,
                                         activeTint: .pink,
                                         inActiveTint: .secondary) {
                                viewModel.updateLike(didLike: !(viewModel.event.didLike ?? false))
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
                            .padding(.vertical, 6)
                        
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
                                Image(systemName: viewModel.event.eventOptions[EventOption.isPrivate.rawValue] ?? false ? "lock.fill" : "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                
                                Text(viewModel.event.eventOptions[EventOption.isPrivate.rawValue] ?? false ? "Private" : "Public")
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
            .frame(height: scrollY > 0 ? 500 + scrollY : 500)  //MARK: Change Flyer Height
        }
        .frame(height: 500)
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
                    .fill(Color.mixerPurpleGradient)
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
