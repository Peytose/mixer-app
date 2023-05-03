//
//  HostMapAnnotation.swift
//  mixer
//
//  Created by Peyton Lyons on 2/8/23.
//

import SwiftUI
import Kingfisher

struct HostMapAnnotation: View {
    var host: CachedHost
    @State private var progress: CGFloat = 0
    let gradient1 = Gradient(colors: [.purple, .pink])
    let gradient2 = Gradient(colors: [.blue, .purple])
    let defaultGradient = Gradient(colors: [.white, .white])
    
    var body: some View {
        VStack {
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .background(alignment: .center) {
                    Circle()
                        .animatableGradient(fromGradient: host.hasCurrentEvent ?? false ? gradient1 : defaultGradient,
                                            toGradient: host.hasCurrentEvent ?? false ? gradient2 : defaultGradient,
                                            progress: progress)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .onAppear {
                            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                                self.progress = 1.0
                            }
                        }
                }
            
            Text(host.name)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
