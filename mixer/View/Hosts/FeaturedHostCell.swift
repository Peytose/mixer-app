//
//  FeaturedHostCell.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import Kingfisher

struct FeaturedHostCell: View {
    let host: CachedHost
    let namespace: Namespace.ID
    @State var showHostView = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(host.name)
                    .font(.largeTitle).bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .matchedGeometryEffect(id: "name", in: namespace)
                
                HStack(spacing: 20) {
                    Text("@\(host.username)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .matchedGeometryEffect(id: "username", in: namespace)
                    
                    Spacer()
                    
                    if let rating = host.rating {
                        HStack(alignment: .center) {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                            
                            Text(rating.roundToDigits(2))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .matchedGeometryEffect(id: "rating", in: namespace)
                            
                            
                        }
                    }
                }
                
                Text(host.bio ?? "")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
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
