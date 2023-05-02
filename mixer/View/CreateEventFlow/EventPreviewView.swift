//
//  EventPreviewView.swift
//  mixer
//
//  Created by Jose Martinez on 5/1/23.
//

import SwiftUI
import MapKit
import TabBar
import Kingfisher

struct EventPreviewView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @State private var isShowingModal   = false
    @State private var currentAmount    = 0.0
    @State private var finalAmount      = 1.0
    @State private var showHost         = false
    @State private var showAllAmenities = false
    @State var showInfoAlert            = false
    var namespace: Namespace.ID
    let coordinates = CLLocationCoordinate2D(latitude: 42.350710, longitude: -71.090980)
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                EventFlyerHeader(viewModel: viewModel, namespace: namespace, isShowingModal: $isShowingModal)
                
                VStack(alignment: .leading, spacing: 20) {
                    HostedBySection(namespace: namespace)
                    
                    content
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What this event offers")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            ForEach(showAllAmenities ? AmenityCategory.allCases : Array(AmenityCategory.allCases.prefix(1)), id: \.self) { category in
                                let amenitiesInCategory = viewModel.selectedAmenities.filter({ $0.category == category }) ?? []
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
                                                        .font(.system(size: 15))
                                                        .padding(.trailing, 5)
                                                } else if amenity == .coatCheck {
                                                    Text("🧥")
                                                        .font(.system(size: 15))
                                                        .padding(.trailing, 5)
                                                } else {
                                                    Image(systemName: amenity.icon)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .foregroundColor(.white)
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
                                                Text(showAllAmenities ? "Show less" : "Show all \(viewModel.selectedAmenities.count ?? 0) amenities")
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Where you'll be")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        MapSnapshotPreview(viewModel: viewModel, location: viewModel.previewCoordinates ?? coordinates)
                    }
                }
                .padding()
                .padding(EdgeInsets(top: 100, leading: 0, bottom: 120, trailing: 0))
            }
            .background(Color.mixerBackground)
            .coordinateSpace(name: "scroll")
            
            if isShowingModal {
                EventImageModalView(viewModel: viewModel, isShowingModal: $isShowingModal)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Description")
                    .font(.title).bold()
                
                Text(viewModel.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            }
            if viewModel.hasNote && !viewModel.note.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes for guest")
                        .font(.title).bold()
                    
                    Text(viewModel.note)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Event details")
                    .font(.title).bold()
                HStack {
                    if viewModel.selectedAmenities.contains(where: { $0.rawValue.contains("Beer") || $0.rawValue.contains("Alcoholic Drinks") }) {
                        DetailRow(image: "drop.fill", text: "Wet Event")
                            .fontWeight(.medium)
                    } else {
                        DetailRow(image: "drop.fill", text: "Dry Event")
                            .fontWeight(.medium)
                    }
                    
                    InfoButton(action: { showInfoAlert.toggle() })
                        .alert("Wet and Dry Events", isPresented: $showInfoAlert, actions: {}, message: {Text("Wet events offer beer/alcohol. Dry events do not offer alcohol.")})
                    
                }
                
                HStack {
                    if viewModel.privacy == .inviteOnly {
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

struct EventPreviewView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        EventPreviewView(viewModel: CreateEventViewModel(),
                        namespace: namespace)
            .preferredColorScheme(.dark)
    }
}

fileprivate struct EventImageModalView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @Binding var isShowingModal: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .backgroundBlur(radius: 10, opaque: true)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isShowingModal = false } }
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.size.width / 1.2)
            }
        }
    }
}

fileprivate struct HostedBySection: View {
    var namespace: Namespace.ID
    @State var isFollowing = false

    var body: some View {
        HStack(spacing: 12) {
                Image("profile-banner-2")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Party hosted by ")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                            
                            Text("MIT Theta Chi")
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
                            withAnimation() {
                                isFollowing.toggle()
                            }
                        } label: {
                                Text(isFollowing ? "Following" : "Follow")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isFollowing ? .white : .black)
                                    .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
                                    .background {
                                        if isFollowing {
                                            Capsule()
                                                .stroke()
                                                .matchedGeometryEffect(id: "eventFollowButton-skdjcn", in: namespace)
                                        } else {
                                            Capsule()
                                                .matchedGeometryEffect(id: "eventFollowButton-skdjcn", in: namespace)
                                        }
                                    }
                        }
                        .buttonStyle(.plain)
                    }
        }
    }
}

fileprivate struct EventFlyerHeader: View {
    @ObservedObject var viewModel: CreateEventViewModel
    var namespace: Namespace.ID
    
    @Binding var isShowingModal: Bool
    @State private var currentAmount = 0.0
    @State private var finalAmount   = 1.0
    @State var isLiked               = false
    
    func formattedDateByDay(text: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: text)
    }
    func formattedDateByHour(text: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: text)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            VStack {
                ZStack {
                    VStack(alignment: .center, spacing: 2) {
                        HStack {
                            Text(viewModel.title)
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
                                Text(formattedDateByDay(text: viewModel.startDate))
                                    .font(.headline)
                                
                                Text("\(formattedDateByHour(text: viewModel.startDate)) - \(formattedDateByHour(text: viewModel.endDate))")
                                    .foregroundColor(.secondary)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                            Spacer()
                            

                            VStack(alignment: .center, spacing: 4) {
                                if viewModel.visibility == ._public {
                                    Image(systemName: "globe")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)

                                    Text("Public")
                                        .foregroundColor(.secondary)
                                } else {
                                    Image(systemName: "lock.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)

                                    Text("Invite Only")
                                        .foregroundColor(.secondary)
                                }
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
                            if let image = viewModel.image {
                                Image(uiImage: image)
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
                            }
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .backgroundBlur(radius: 10, opaque: true)
                                .mask(
                                    RoundedRectangle(cornerRadius: 20)
                                )
                            if let image = viewModel.image {
                                Image(uiImage: image)
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


fileprivate struct MapSnapshotPreview: View {
    @ObservedObject var viewModel: CreateEventViewModel

    let location: CLLocationCoordinate2D
    var span: CLLocationDegrees = 0.001
    var delay: CGFloat          = 0.3
    var width: CGFloat          = 350
    var height: CGFloat         = 220
    @State private var mapPreviewImageView: Image?
    
    var body: some View {
        Group {
            if let image = mapPreviewImageView {
                ZStack(alignment: .center) {
                    image
                    
                    EventMapAnnotationPreview(viewModel: viewModel)
                }
                .cornerRadius(9)
            } else {
                LoadingView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                generateSnapshot(width: width, height: height)
            }
        }
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true
        mapOptions.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
        
        let bgQueue = DispatchQueue.global(qos: .background)
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start(with: bgQueue, completionHandler: { snapshot, error in
            if let error = error {
                print("DEBUG: Error generating snapshot. \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            self.mapPreviewImageView = Image(uiImage: snapshot.image)
        })
    }
}

fileprivate struct EventMapAnnotationPreview: View {
    @ObservedObject var viewModel: CreateEventViewModel
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .background(alignment: .center) {
                        Circle()
                            .frame(width: 50, height: 50)
                            .shadow(radius: 10)
                    }
            }
            
            Text(viewModel.title)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
