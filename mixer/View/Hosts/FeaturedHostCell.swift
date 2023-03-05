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
 Comments:
 Make the follower count optional[''
 
 General Comments:
 1. I still need to go back and implement the matched geometry effect.
 2. I got rid of the rating section. I don't think its appropriate in this view especially considering the limited real estate. Maybe in the actual host homepage?
 */
import SwiftUI
import Kingfisher

struct FeaturedHostCell: View {
    let host: CachedHost
    let namespace: Namespace.ID
    @State var showHostView = false
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
                }
                
                HStack(spacing: 10) {
                    Text("@\(host.username)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "username", in: namespace)
                    
                    Spacer()
                }
                
                Text(host.bio ?? "")
                    .font(.subheadline.weight(.regular))
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
