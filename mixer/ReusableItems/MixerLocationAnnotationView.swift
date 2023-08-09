//
//  MixerLocationAnnotationView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/31/23.
//

import SwiftUI
import CoreLocation
import Kingfisher
import MapKit

struct MixerLocationAnnotationView: View {
    let annotation: MixerLocationAnnotation
    
    var body: some View {
        VStack {
            if let imageUrl = annotation.imageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .background(alignment: .center) {
                        Circle()
                            .frame(width: annotation.state == .host ? 40 : 50, height: annotation.state == .host ? 40 : 50)
                            .clipShape(Circle().stroke(lineWidth: annotation.state == .host ? 5 : 0))
                            .shadow(radius: 10)
                    }
            }
            
            if let title = annotation.title {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
}

struct MixerLocationAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        MixerLocationAnnotationView(annotation: MixerLocationAnnotation(location: MixerLocation(host: dev.mockHost)))
    }
}
