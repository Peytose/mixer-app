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
    @State private var animateParticles = false

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
//                .opacity(host.hasCurrentEvent ?? false ? 1.0 : 0.5)
//                .particleEffect2(systemImage: "heart.fill", font: .body, status: animateParticles, activeTint: .pink, inActiveTint: .secondary)
//                .onAppear {
//                    startParticlesAnimation()
//                }
            
            Text(host.name)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
    private func startParticlesAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animateParticles = true
        }
    }
}

struct HostMapAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        HostMapAnnotation(host: CachedHost(from: Mockdata.host))
            .preferredColorScheme(.dark)
    }
}
