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

struct EventDetailView: View {
    @ObservedObject var viewModel: EventDetailViewModel
    @State private var isShowingModal   = false
    @State private var currentAmount    = 0.0
    @State private var finalAmount      = 1.0
    @State private var showHost         = false
    @State private var showAllAmenities = false
    @State var showInfoAlert            = false
    var namespace: Namespace.ID

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                EventFlyerHeader(event: viewModel.event,
                                 unsave: viewModel.unsave,
                                 save: viewModel.save,
                                 namespace: namespace,
                                 isShowingModal: $isShowingModal)
                
                VStack(alignment: .leading, spacing: 20) {
                    HostedBySection(viewModel: viewModel,
                                    namespace: namespace)
                    .onTapGesture {
                        showHost.toggle()
                    }
                    
                    content
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What this event offers")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            ForEach(showAllAmenities ? AmenityCategory.allCases : Array(AmenityCategory.allCases.prefix(1)), id: \.self) { category in
                                let amenitiesInCategory = viewModel.event.amenities?.filter({ $0.category == category }) ?? []
                                if !amenitiesInCategory.isEmpty {
                                    Section(header: Text(category.rawValue).font(.headline).padding(.vertical, 2)) {
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
                                                Text(showAllAmenities ? "Show less" : "Show all \(viewModel.event.amenities?.count ?? 0) amenities")
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
                    
                    if let coords = viewModel.coordinates {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Where you'll be")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                MapSnapshotView(location: coords, event: viewModel.event)
                                    .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coords) }
                                
                                Text("Tap the map for directions to this event!")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
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
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
        .sheet(isPresented: $showHost) {
            if let host = viewModel.host {
                HostDetailView(viewModel: HostDetailViewModel(host: host), namespace: namespace)
            }
        }
        .task {
            viewModel.checkIfUserSavedEvent()
            viewModel.fetchEventHost()
            viewModel.getEventCoordinates()
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Description")
                    .font(.title).bold()
                
                Text(viewModel.event.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            }
            
            if let notes = viewModel.event.notes {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes for guest")
                        .font(.title).bold()
                    
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Event details")
                    .font(.title).bold()
                HStack {
                    if let amenities = viewModel.event.amenities {
                        if amenities.contains(where: { $0.rawValue.contains("Beer") || $0.rawValue.contains("Alcoholic Drinks") }) {
                            DetailRow(image: "drop.fill", text: "Wet Event")
                                .fontWeight(.medium)
                        } else {
                            DetailRow(image: "drop.fill", text: "Dry Event")
                                .fontWeight(.medium)
                        }
                    }
                    
                    InfoButton(action: { showInfoAlert.toggle() })
                        .alert("Wet and Dry Events", isPresented: $showInfoAlert, actions: {}, message: {Text("Wet events offer beer/alcohol. Dry events do not offer alcohol.")})
                }
                
                HStack {
                    if viewModel.event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false {
                        DetailRow(image: "list.clipboard.fill", text: "Invite Only Event")
                            .fontWeight(.medium)
                    } else {
                        DetailRow(image: "list.clipboard.fill", text: "Open Event")
                            .fontWeight(.medium)
                    }
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
                        
                        //MARK: Follow host button on event (debug report: same as other follow button(s))
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.follow) { viewModel.followHost() }
                        } label: {
                            if let isFollowed = host.isFollowed {
                                Text(isFollowed ? "Following" : "Follow")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isFollowed ? .white : .black)
                                    .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
                                    .background {
                                        if isFollowed {
                                            Capsule()
                                                .stroke()
                                                .matchedGeometryEffect(id: "eventFollowButton-\(viewModel.event.id)", in: namespace)
                                        } else {
                                            Capsule()
                                                .matchedGeometryEffect(id: "eventFollowButton-\(viewModel.event.id)", in: namespace)
                                        }
                                    }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                
            }
        }
    }
}

fileprivate struct EventFlyerHeader: View {
    let event: CachedEvent
    let unsave: () -> Void
    let save: () -> Void
    var namespace: Namespace.ID
    
    @Binding var isShowingModal: Bool
    @State private var currentAmount = 0.0
    @State private var finalAmount   = 1.0
    @State var isLiked               = false

    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            VStack {
                ZStack {
                    VStack(alignment: .center, spacing: 2) {
                        HStack {
                            Text(event.title)
                                .font(.title)
                                .bold()
                                .foregroundColor(.primary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.65)
                            
                            Spacer()
                            
                            CustomButton(systemImage: "heart.fill", status: isLiked, activeTint: .pink, inActiveTint: .secondary) {
                                isLiked.toggle()
                            }
                        }
                        
                        Divider()
                            .foregroundColor(.secondary)
                            .padding(.vertical, 6)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.startDate.getTimestampString(format: "EEEE, MMMM d"))
                                    .font(.headline)
                                
                                Text("\(event.startDate.getTimestampString(format: "h:mm a")) - \(event.endDate.getTimestampString(format: "h:mm a"))")
                                    .foregroundColor(.secondary)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false ? "lock.fill" : "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                
                                Text(event.eventOptions[EventOption.isInviteOnly.rawValue] ?? false ? "Invite Only" : "Public")
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
                            KFImage(URL(string: event.eventImageUrl))
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
                            
                            KFImage(URL(string: event.eventImageUrl))
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
