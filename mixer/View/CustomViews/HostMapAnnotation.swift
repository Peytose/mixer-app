//
//  HostMapAnnotation.swift
//  mixer
//
//  Created by Peyton Lyons on 2/8/23.
//

import SwiftUI
import Kingfisher
import ConfettiSwiftUI

struct HostMapAnnotation: View {
    var host: CachedHost
    @State private var progress: CGFloat = 1.0
    let gradient1 = Gradient(colors: [.purple, .pink])
    let gradient2 = Gradient(colors: [.blue, .purple])
    let defaultGradient = Gradient(colors: [.white, .white])

    @State private var counter: Int = 0

    var body: some View {
        VStack {
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .background {
                    Circle()
                        .animatableGradient(fromGradient: host.hasCurrentEvent ?? false ? gradient1 : defaultGradient,
                                            toGradient: host.hasCurrentEvent ?? false ? gradient2 : defaultGradient,
                                            progress: progress)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle().stroke(lineWidth: 5))
                        .shadow(radius: 10)
                        .onAppear {
                            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                                self.progress = 1.0
                            }
                        }
                }
                .confettiCannon(counter: $counter,
                                num: 30,
                                rainHeight: 150,
                                openingAngle: Angle(degrees: 0),
                                closingAngle: Angle(degrees: 360),
                                radius: 80)
            
            Text(host.name)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .onAppear {
            if host.hasCurrentEvent ?? false {
                startAnimatingCounter()
            }
        }
    }
    
    func startAnimatingCounter() {
        // Start a timer to increment the counter every 1 second
        Timer.scheduledTimer(withTimeInterval: TimeInterval(Int.random(in: 2...5)), repeats: true) { timer in
            counter += 1
        }
    }
}

struct HostMapAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        HostMapAnnotation(host: CachedHost(from: Mockdata.host))
            .preferredColorScheme(.dark)
    }
}
