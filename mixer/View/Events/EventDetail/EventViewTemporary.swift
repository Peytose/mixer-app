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

struct EventView: View {
    @ObservedObject var viewModel: EventDetailViewModel
    @State private var showFullFlyer = false
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
    @State private var showHost = false
    
//    var event: MockEvent
    let event: CachedEvent
    let host: CachedHost
    let unsave: () -> Void
    let save: () -> Void
    let coordinates: CLLocationCoordinate2D?
//    @Binding var showAllAmenities: Bool
    @State private var showAllAmenities = false

    var namespace: Namespace.ID

    let link = URL(string: "https://mixer.llc")!
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(showsIndicators: false) {
                    cover
                    
                    content
                }
                .background(Color.mixerBackground)
                .coordinateSpace(name: "scroll")
                
                joinButton
                
                if showFullFlyer {
                    popUp
                        .transition(.scale(scale: 0.01))
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .ignoresSafeArea()
            .overlay {
                closeButton
            }
//            .sheet(isPresented: $showHost) {
//                HostOrganizationView(viewModel: ExplorePageViewModel(), namespace: namespace)
//            }
        }
    }
    
    var cover: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            VStack {
                ZStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(event.title)
                                .font(.title)
                                .bold()
                                .foregroundColor(.primary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.65)
                                .matchedGeometryEffect(id: event.title, in: namespace)
                            
                            Spacer()
                            
                            if event.hasStarted == false {
                                if let didSave = event.didSave {
                                    Button {
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                        withAnimation() {
                                            didSave ? unsave() : save()
                                        }
                                    } label: {
                                        Image(systemName: didSave ? "bookmark.fill" : "bookmark")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(didSave ? Color.yellow : Color.white)
                                            .frame(width: 19, height: 19)
                                            .offset(y: 1)
                                            .padding(5)
                                            .background(.ultraThinMaterial)
                                            .backgroundStyle(cornerRadius: 18, opacity: 0.4)
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 5) {
                            Image(systemName: "person.3.fill")
                                .symbolRenderingMode(.hierarchical)
                            
                            if let saves = event.saves {
                                Text("\(saves) interested")
                                    .font(.callout.weight(.semibold))

                            }

                            Spacer()
                            
                            HStack(spacing: -8) {
                                Image("profile-banner-1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                
                                Image("mock-user-1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                
                                Circle()
                                    .fill(Color.mixerSecondaryBackground)
                                    .frame(width: 30, height: 30)
                                    .overlay(alignment: .center) {
                                        Text("+99")
                                            .foregroundColor(.white)
                                            .font(.footnote)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                    }
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
                            .matchedGeometryEffect(id: "\(event.title)-time", in: namespace)
                            
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: event.isInviteOnly ? "lock.fill" : "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .background(.ultraThinMaterial)
                                    .backgroundStyle(cornerRadius: 10, opacity: 0.6)
                                    .cornerRadius(10)
                                
                                Text(event.isInviteOnly ? "Invite Only" : "Public")
                                    .foregroundColor(.secondary)
                                
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .matchedGeometryEffect(id: "\(event.title)-isInviteOnly", in: namespace)
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
                                .matchedGeometryEffect(id: "background 2", in: namespace)
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
                                .matchedGeometryEffect(id: "background 1", in: namespace)
                                .offset(y: scrollY > 0 ? -scrollY : 0)
                                .mask(
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: proxy.size.width - 40, height: proxy.size.height - 50)
                                )
                                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                                .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                                .scaleEffect(finalAmount + currentAmount)
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                                    impact.impactOccurred()
                                    withAnimation() {
                                        showFullFlyer.toggle()
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
    
    var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink {
                HostDetailView(viewModel: HostDetailViewModel(host: host),
                               namespace: namespace)
            } label: {
                HostedBySection(type: event.type,
                                host: host,
                                ageLimit: event.ageLimit,
                                cost: event.cost,
                                hasAlcohol: event.alcoholPresence,
                                namespace: namespace)
            }
            .buttonStyle(.plain)
            
            aboutSection

            eventDetails

            eventAmenities
            
            Text("Where you'll be")
                .font(.title).bold()
            
            if let coords = coordinates {
                MapSnapshotView(location: coordinates!)
                //                    .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coordinates) }
            }
            
            Text("Friends Attending")
                .font(.title).bold()
                .padding(.bottom, 10)
            
//            ForEach(Array(results.enumerated().prefix(9)), id: \.offset) { index, user in
//                if index != 0 { Divider() }
//                NavigationLink(destination: UserProfileView(viewModel: ExplorePageViewModel(), user: user)) {
//                    HStack(spacing: 15) {
//                        Image(user.image)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .clipShape(Circle())
//                            .frame(width: 40, height: 40)
//
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Text(user.name)
//                                    .font(.system(size: 18, weight: .semibold, design: .default))
//                                    .lineLimit(1)
//                                    .foregroundColor(.white)
//
//                                Text(user.school)
//                                    .font(.system(size: 18, weight: .semibold, design: .default))
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                    .padding(.vertical, -16)
//                }
//            }
        }
        .padding()
        .padding(EdgeInsets(top: 100, leading: 0, bottom: 120, trailing: 0))
    }
    
    var closeButton: some View {
        Button {
            if showFullFlyer {
                withAnimation() {
                    showFullFlyer.toggle()
                }
            } else {
                withAnimation() {
//                    viewModel.showEventView.toggle()
//                    viewModel.showNavigationBar.toggle()
//                    tabBarVisibility = .visible
                }
            }
        } label: { XDismissButton() }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(20)
            .padding(.top, 35)
            .ignoresSafeArea()
    }
    
    var joinButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }, label: {
            HStack {
                Image(systemName: "list.clipboard")
                    .imageScale(.large)
                
                Text("Join Guestlist")
                    .font(.title3.weight(.semibold))
            }
            .foregroundColor(.white)
            .padding()
            .background {
                Capsule()
                    .fill(Color.mixerPurpleGradient)
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 30)
    }
    
//    var results: [MockUser] {
//        return users
//    }
    
    var popUp: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .backgroundBlur(radius: 10, opaque: true)
                    .ignoresSafeArea()
                
                KFImage(URL(string: viewModel.event.eventImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 370, height: 435)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .aspectRatio(contentMode: .fit)
                    .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
            }
        }
    }
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About this event")
                .font(.title).bold()
                .padding(.bottom, -14)
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4)
            
            Text("Notes for guest")
                .font(.title).bold()
                .padding(.bottom, -14)
            
            Text("This is where the notes for the event would be")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4)
        }
    }
    
    var eventDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Event details")
                .font(.title).bold()
            
            VStack(alignment: .leading) {
                DetailRow(image: "sparkles", text: "Neon/black light")

                DetailRow(image: "tshirt.fill", text: "N/A")
                
//                HStack {
//                    Image(systemName: "mappin.and.ellipse")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 21, height: 21)
//                        .padding(8)
//                        .background(.ultraThinMaterial)
//                        .backgroundStyle(cornerRadius: 10, opacity: 0.6)
//
//                    VStack(alignment: .leading) {
//                        Text("528 Beacon St")
//
//                        Text("Boston, MA 02215")
//                            .foregroundColor(.secondary)
//                    }
//                    .fontWeight(.semibold)
//                }
//                .onTapGesture {
//                    let latitude = 42.3507046
//                    let longitude = -71.0909822
//                    let url = URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)")
//                    if UIApplication.shared.canOpenURL(url!) {
//                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//                    }
//                }
            }
            .font(.headline)
        }
    }
    
    var eventAmenities: some View {
        VStack(alignment: .leading, spacing: 20) {
//            Text("Amenities")
//                .font(.title).bold()
//                .padding(.bottom, -14)
            ScrollView {
                VStack(alignment: .leading) {
                    Text("What this event offers")
                        .font(.title2)
                        .bold()
                    
                    ForEach(showAllAmenities ? AmenityCategory.allCases : Array(AmenityCategory.allCases.prefix(1)), id: \.self) { category in
                        if let amenitiesInCategory = event.amenities.filter({ $0.category == category }), !amenitiesInCategory.isEmpty {
                            Section(header: Text(category.rawValue)) {
                                ForEach(amenitiesInCategory, id: \.self) { amenity in
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
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation() {
                                showAllAmenities.toggle()
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.DesignCodeWhite)
                                    .frame(width: 350, height: 45)
                                
                                Text(showAllAmenities ? "Show less" : "Show all \(event.amenities.count) amenities")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }

//            ScrollView {
//                VStack(alignment: .leading) {
//                    Text("What this event offers")
//                        .font(.title2)
//                        .bold()
//
//                    ForEach(AmenityCategory.allCases, id: \.self) { category in
//                        Section(header: Text(category.rawValue)) {
//                            ForEach(event.amenities.filter { $0.category == category }.prefix(showAllAmenities ? event.amenities.count : 3), id: \.self) { amenity in
//                                HStack {
//                                    Image(systemName: amenity.icon)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 15, height: 15)
//
//                                    Text(amenity.rawValue)
//                                        .font(.body)
//                                        .foregroundColor(.secondary)
//
//                                    Spacer()
//                                }
//                            }
//                        }
//                    }
//
//                    HStack {
//                        Spacer()
//
//                        Button {
//                            withAnimation() {
//                                showAllAmenities.toggle()
//                            }
//
//                        } label: {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .foregroundColor(.DesignCodeWhite)
//                                    .frame(width: 350, height: 45)
//
//                                Text(showAllAmenities ? "Show less" : "Show all \(event.amenities.count) amenities")
//                                    .font(.body)
//                                    .fontWeight(.medium)
//                                    .foregroundColor(.black)
//                            }
//                        }
//                        Spacer()
//                    }
//                    Spacer()
//                }
//            }

//            ScrollView {
//                VStack(alignment: .leading) {
//                    Text("What this event offers")
//                        .font(.title2)
//                        .bold()
//
//
//                    ForEach(event.amenities.prefix(showAllAmenities ? event.amenities.count : 4), id: \.self) { amenity in
//                        HStack {
//                            Image(systemName: amenity.icon)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 15, height: 15)
//
//                            Text(amenity.rawValue)
//                                .font(.body)
//                                .foregroundColor(.secondary)
//
//                            Spacer()
//                        }
//                    }
//
//                    HStack {
//                        Spacer()
//
//                        Button {
//                            withAnimation() {
//                                showAllAmenities.toggle()
//                            }
//
//                        } label: {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .foregroundColor(.DesignCodeWhite)
//                                    .frame(width: 350, height: 45)
//
//                                Text("Show all \(event.amenities.count) amenities")
//                                    .font(.body)
//                                    .fontWeight(.medium)
//                                    .foregroundColor(.black)
//                            }
//                        }
//                        Spacer()
//                    }
//                    Spacer()
//                }
//            }
//            ScrollView {
//                VStack(alignment: .leading) {
//                    Text("What this event offers")
//                        .font(.title2)
//                        .bold()
//
//                    ForEach(AmenityCategory.allCases, id: \.self) { category in
//                        Section(header: Text(category.rawValue)) {
//                            ForEach(event.amenities.filter { $0.category == category }, id: \.self) { amenity in
//                                HStack {
//                                    Image(systemName: amenity.icon)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 15, height: 15)
//
//                                    Text(amenity.rawValue)
//                                        .font(.body)
//                                        .foregroundColor(.secondary)
//
//                                    Spacer()
//                                }
//                            }
//                        }
//                    }
//
//                    HStack {
//                        Spacer()
//
//                        Button {
//                            withAnimation() {
//                                showAllAmenities.toggle()
//                            }
//
//                        } label: {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .foregroundColor(.DesignCodeWhite)
//                                    .frame(width: 350, height: 45)
//
//                                Text("Show all \(event.amenities.count) amenities")
//                                    .font(.body)
//                                    .fontWeight(.medium)
//                                    .foregroundColor(.black)
//                            }
//                        }
//                        Spacer()
//                    }
//                    Spacer()
//                }
//            }

        }
    }
    
    private struct PaddedImage: View {
        var image: String
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
}

struct EventView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        EventView(viewModel: EventDetailViewModel(event: CachedEvent(from: Mockdata.event)), event: CachedEvent(from: Mockdata.event),
                  host: CachedHost(from: Mockdata.host),
                  unsave: {},
                  save: {},
                  coordinates: CLLocationCoordinate2D(latitude: 40, longitude: 50),
                  namespace: namespace)
            .preferredColorScheme(.dark)
    }
}

fileprivate struct HostedBySection: View {
    let type: EventType
    let host: CachedHost
    var ageLimit: Int?
    var cost: Float?
    var hasAlcohol: Bool?
    let dot: Text = Text("•").font(.callout).foregroundColor(.secondary)
    var namespace: Namespace.ID
    @State private var isFollowing = false

    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 45, height: 45)
                        
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("\(type.rawValue) by \(host.name)")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Color.mixerIndigo)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(isFollowing ? .white : .black)
                        .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
                        .background {
                            if isFollowing {
                                Capsule()
                                    .stroke()
                                    .matchedGeometryEffect(id: "\(host.id)eventFollowButton", in: namespace)
                            } else {
                                Capsule()
                                    .matchedGeometryEffect(id: "\(host.id)eventFollowButton", in: namespace)
                            }
                            
                        }
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.follow) {
                                isFollowing.toggle()
                            }
                        }
                }
                
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
        }
    }
}
