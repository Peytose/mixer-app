//
//  StretchablePhotoBanner.swift
//  mixer
//
//  Created by Peyton Lyons on 1/28/23.
//

import SwiftUI
import Kingfisher

struct StretchablePhotoBanner: View {
    let imageUrl: String
    var namespace: Namespace.ID?
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width, height: DeviceTypes.ScreenSize.height / 2.3)
                .mask(Color.theme.profileGradient) // mask the blurred image using the gradient's alpha values
                .offset(y: scrollY > 0 ? -scrollY : 0)
                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}

struct StretchablePhotoBannerJose: View {
    let imageUrl: String
    var namespace: Namespace.ID?
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            ZStack {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.size.width, height: DeviceTypes.ScreenSize.height / 2)
                    .offset(y: scrollY > 0 ? -scrollY : 0)
                    .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                    .blur(radius: scrollY > 0 ? scrollY / 20 : 0)
                    .opacity(0.9)
                //                    .cornerRadius(20, corners: [.bottomLeft, .bottomRight, .topRight, .topLeft])
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .backgroundBlur(radius: 10, opaque: true)
                    .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.size.width, height: DeviceTypes.ScreenSize.height)
                    .mask(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: proxy.size.width - 40, height: proxy.size.height)
                    )
                    .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                    .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                    .zIndex(2)
            }
        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

//UI Model
//fileprivate struct EventFlyerHeader: View {
//    let event: CachedEvent
//    let unsave: () -> Void
//    let save: () -> Void
//    var namespace: Namespace.ID
//
//    @Binding var showFullFlyer: Bool
//    @State private var currentAmount = 0.0
//    @State private var finalAmount = 1.0
//
//    var body: some View {
//        GeometryReader { proxy in
//            let scrollY = proxy.frame(in: .named("scroll")).minY
//            VStack {
//                ZStack {
//                    //Modal
//                    VStack(alignment: .leading, spacing: 2) {
//                        HStack {
//                            Text(event.title)
//                                .font(.title)
//                                .bold()
//                                .foregroundColor(.primary)
//                                .lineLimit(2)
//                                .minimumScaleFactor(0.65)
//                                .matchedGeometryEffect(id: event.title, in: namespace)
//
//                            Spacer()
//
//                            if event.hasStarted == false {
//                                if let didSave = event.didSave {
//                                    Button {
//                                        let impact = UIImpactFeedbackGenerator(style: .light)
//                                        impact.impactOccurred()
//                                        withAnimation() {
//                                            didSave ? unsave() : save()
//                                        }
//                                    } label: {
//                                        Image(systemName: didSave ? "bookmark.fill" : "bookmark")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .foregroundColor(didSave ? Color.yellow : Color.white)
//                                            .frame(width: 19, height: 19)
//                                            .offset(y: 1)
//                                            .padding(5)
//                                            .background(.ultraThinMaterial)
//                                            .backgroundStyle(cornerRadius: 18, opacity: 0.4)
//                                    }
//                                }
//                            }
//                        }
//
//                        HStack(spacing: 5) {
//                            Image(systemName: "person.3.fill")
//                                .symbolRenderingMode(.hierarchical)
//
//                            if let saves = event.saves {
//                                Text("\(saves) interested")
//                                    .font(.callout.weight(.semibold))
//
//                            }
//
//                            Spacer()
//
//                            HStack(spacing: -8) {
//                                Image("profile-banner-1")
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 30, height: 30)
//                                    .clipShape(Circle())
//
//                                Image("mock-user-1")
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 30, height: 30)
//                                    .clipShape(Circle())
//
//                                Circle()
//                                    .fill(Color.mixerSecondaryBackground)
//                                    .frame(width: 30, height: 30)
//                                    .overlay(alignment: .center) {
//                                        Text("+99")
//                                            .foregroundColor(.white)
//                                            .font(.footnote)
//                                            .lineLimit(1)
//                                            .minimumScaleFactor(0.5)
//                                    }
//                            }
//                        }
//
//                        Divider()
//                            .foregroundColor(.secondary)
//                            .padding(.vertical, 6)
//
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text(event.startDate.getTimestampString(format: "EEEE, MMMM d"))
//                                    .font(.headline)
//
//                                Text("\(event.startDate.getTimestampString(format: "h:mm a")) - \(event.endDate.getTimestampString(format: "h:mm a"))")
//                                    .foregroundColor(.secondary)
//                            }
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.75)
//                            .matchedGeometryEffect(id: "\(event.title)-time", in: namespace)
//
//                            Spacer()
//
//                            VStack(alignment: .center, spacing: 4) {
//                                Image(systemName: event.isInviteOnly ? "lock.fill" : "globe")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 20, height: 20)
//                                    .background(.ultraThinMaterial)
//                                    .backgroundStyle(cornerRadius: 10, opacity: 0.6)
//                                    .cornerRadius(10)
//
//                                Text(event.isInviteOnly ? "Invite Only" : "Public")
//                                    .foregroundColor(.secondary)
//
//                            }
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.75)
//                            .matchedGeometryEffect(id: "\(event.title)-isInviteOnly", in: namespace)
//                        }
//                        .font(.callout.weight(.semibold))
//                    }
//                    .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14))
//                    .background(
//                        Rectangle()
//                            .fill(.ultraThinMaterial)
//                            .backgroundStyle(cornerRadius: 30)
//                    )
//                    .frame(maxHeight: .infinity, alignment: .bottom)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .offset(y: 120)
//                    .background(
//                        ZStack {
////                            KFImage(URL(string: event.eventImageUrl))
//                            Image("theta-chi-party-poster")
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .matchedGeometryEffect(id: "background 2", in: namespace)
//                                .offset(y: scrollY > 0 ? -scrollY : 0)
//                                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
//                                .blur(radius: scrollY > 0 ? scrollY / 20 : 0)
//                                .opacity(0.9)
//                                .mask(
//                                    RoundedRectangle(cornerRadius: 20)
//                                )
//
//                            Rectangle()
//                                .fill(Color.clear)
//                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                                .backgroundBlur(radius: 10, opaque: true)
//                                .mask(
//                                    RoundedRectangle(cornerRadius: 20)
//                                )
//
////                            KFImage(URL(string: event.eventImageUrl))
//                            Image("theta-chi-party-poster")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: proxy.size.width, height: proxy.size.height)
//                                .matchedGeometryEffect(id: "background 1", in: namespace)
//                                .offset(y: scrollY > 0 ? -scrollY : 0)
//                                .mask(
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .frame(width: proxy.size.width - 40, height: proxy.size.height - 50)
//                                )
//                                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
//                                .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
//                                .scaleEffect(finalAmount + currentAmount)
//                                .onLongPressGesture(minimumDuration: 0.1) {
//                                    let impact = UIImpactFeedbackGenerator(style: .heavy)
//                                    impact.impactOccurred()
//                                    withAnimation() {
//                                        showFullFlyer.toggle()
//                                    }
//                                }
//                                .zIndex(2)
//                        }
//                    )
//                    .offset(y: scrollY > 0 ? -scrollY * 1.8 : 0)
//                }
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: scrollY > 0 ? 500 + scrollY : 500)  //MARK: Change Flyer Height
//        }
//        .frame(height: 500)
//    }
//}

struct HostBannerView: View {
    let host: Host
    var namespace: Namespace.ID?
    
    var body: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height * 0.4)
                .mask(Color.theme.profileGradient) // mask the blurred image using the gradient's alpha values
                .offset(y: scrollY > 0 ? -scrollY : 0)
                .scaleEffect(scrollY > 0 ? scrollY / 500 + 1 : 1)
                .blur(radius: scrollY > 0 ? scrollY / 40 : 0)
                .matchedGeometryEffect(id: "image-\(host.username)",
                                       in: namespace ?? Namespace().wrappedValue)
                .mask {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .matchedGeometryEffect(id: "corner-mask-\(host.username)",
                                               in: namespace ?? Namespace().wrappedValue)
                }
        }
        .frame(width: DeviceTypes.ScreenSize.width, height: DeviceTypes.ScreenSize.height / 2.5)
    }
}
