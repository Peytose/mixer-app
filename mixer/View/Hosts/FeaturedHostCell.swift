//
//  FeaturedHostCell.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//
//MARK:  Notes for Peyton
/*
 I've added the following elements:
 
 1. Dynamic Follow Button
 Components:
 1. @State variable isFollowing triggers an animated UI change on the button
 2. Button itself is a Text view with a capsule stroke background
 Comments:
 The button itself is just a UI View with a state variable to animate changes when touched. Be sure to add actual functionality to it. I need to do a better job of animating the change. Right now the text translates on the y-axis which is not ideal
 
 2. Verified Checkmark
 Components:
 1. Badge - is an sf symbol "checkmark.seal.fill" with a template rendering mode modifier applied to it to achieve the desired color palette
 2. @State variable showAlert triggers an alert to be shown
 3. Alert - an IOS alert that pops up upon the verified badge being clicked.

 3. Social/share links
 Components:
 1. Instagram link - is the official instagram black glyph icon svg. I read their official website about it and as long as we don't mess with the logo or name, or present them in a bad light, we are good to go.
     See https://about.meta.com/brand/resources/instagram/instagram-brand/
 2. Website link - is an sf symbol "globe"
 3. Share link - is an sf symbol "square.and.arrow.up" that presents a share sheet upon being clicked.
 Comments:
 All of these links use a temporary link constant called link I intialized before the body. Be sure to replace this placeholder link with the host's actual links
 
 4. Follower count
 Components:
 1. Text -  Just a simple text view.
 
 General Comments:
 1. I still need to go back and implement the matched geometry effect.
 2. Should we even have the alert in this view? I think it should only be in the actual host homepage view. Thoughts?
 3. I got rid of the rating section. I don't think its appropriate in this view especially considering the limited real estate. Maybe in the actual host homepage?
 */
import SwiftUI
import Kingfisher

struct FeaturedHostCell: View {
    let host: CachedHost
    let namespace: Namespace.ID
    @State var showHostView = false
    @State var showAlert = false
    @State var isFollowing = false
    let link = URL(string: "https://mixer.llc")! // Temporary url for UI prototype

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(host.name)
                        .font(.largeTitle).bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .matchedGeometryEffect(id: "name", in: namespace)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring()) {
                                showAlert.toggle()
                            }
                            
                        }
                        .alert("Verified Host", isPresented: $showAlert, actions: {}) {
                            Text("Verified badges are awarded to hosts that have provided proof of identity and have demonstrated that they have the necessary experience and qualifications to host a safe event")
                        }
                        .matchedGeometryEffect(id: "checkmark", in: namespace)
                    
                    Spacer()
                    
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                        .background {
                            Capsule()
                                .stroke()
                        }
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring()) {
                                isFollowing.toggle()
                            }
                        }
                        .matchedGeometryEffect(id: "follow", in: namespace)
                }
                
                HStack(spacing: 10) {
                    Text("@\(host.username)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "username", in: namespace)
                    
                    Spacer()
                    
                    Link(destination: link) {
                        Image("instagram-glyph-icon-black")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                    }
                    .matchedGeometryEffect(id: "instagram", in: namespace)
                    
                    Link(destination: link) {
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.white)
                            .frame(width: 22, height: 22)
                    }
                    .matchedGeometryEffect(id: "website", in: namespace)
                    
                    ShareLink(item: link) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.medium)
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                    .matchedGeometryEffect(id: "share", in: namespace)
                    
//                    if let rating = host.rating {
//                        HStack(alignment: .center) {
//                            Image(systemName: "star.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .foregroundColor(.white)
//                                .frame(width: 20, height: 20)
//
//                            Text(rating.roundToDigits(2))
//                                .font(.subheadline)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.secondary)
//                                .lineLimit(1)
//                                .minimumScaleFactor(0.7)
//                                .matchedGeometryEffect(id: "rating", in: namespace)
//
//
//                        }
//                    }
                }
                Text("1845 Followers")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .matchedGeometryEffect(id: "subtitle", in: namespace)
                
                Text(host.bio ?? "")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .matchedGeometryEffect(id: "bio", in: namespace)
            }
            .padding(20)
            .padding(.bottom, -5)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.8))
                    .background(Color.mixerBackground.opacity(0.2))
                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(-10)
                    .padding(.horizontal, -15)
                    .blur(radius: 30)
                    .matchedGeometryEffect(id: "blur", in: namespace)
            )
        }
        .foregroundStyle(.white)
        .background(
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .mask(Color.profileGradient) /// mask the blurred image using the gradient's alpha values
                .matchedGeometryEffect(id: "image", in: namespace)
        )
        .mask(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        )
        .frame(width: 350, height: 300)
        .padding(20)
        .preferredColorScheme(.dark)
    }
}

//struct FeaturedHostCard_Previews: PreviewProvider {
//    @Namespace static var namespace
//    
//    static var previews: some View {
//        FeaturedHostCell(host: Mockdata.host, namespace: namespace)
//    }
//}
