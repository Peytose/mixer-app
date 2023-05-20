//
//  ParticleEffectModifier+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 4/30/23.
//

import SwiftUI
import Combine

/// Particle Model
struct Particle: Identifiable {
    var id: UUID = .init()
    var randomX: CGFloat = 0
    var randomY: CGFloat = 0
    var scale: CGFloat = 1
    /// Optional
    var opacity: CGFloat = 1
    
    /// Reset's All Properties
    mutating func reset() {
        randomX = 0
        randomY = 0
        scale = 1
        opacity = 1
    }
}

/// Custom View Modifier
extension View {
    @ViewBuilder
    func particleEffect(systemImage: String, font: Font, status: Bool, activeTint: Color, inActiveTint: Color) -> some View {
        self
            .modifier(
                ParticleModifier(systemImage: systemImage, font: font, status: status, activeTint: activeTint, inActiveTint: inActiveTint)
            )
    }
    
    @ViewBuilder
    func particleEffect2(systemImage: String, font: Font, status: Bool, activeTint: Color, inActiveTint: Color) -> some View {
        self
            .modifier(
                ParticleModifier2(systemImage: systemImage, font: font, status: status, activeTint: activeTint, inActiveTint: inActiveTint)
            )
    }
}

fileprivate struct ParticleModifier: ViewModifier {
    var systemImage: String
    var font: Font
    var status: Bool
    var activeTint: Color
    var inActiveTint: Color
    /// View Properties
    @State private var particles: [Particle] = []
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        Image(systemName: systemImage)
                            .font(font)
                            .foregroundColor(status ? activeTint : inActiveTint)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                            /// Only Visible When Status is Active
                            .opacity(status ? 1 : 0)
                            /// Making Base Visibility With Zero Animation
                            .animation(.none, value: status)
                    }
                }
                .onAppear {
                    /// Adding Base Particles For Animation
                    if particles.isEmpty {
                        /// Change Count as per your wish
                        for _ in 1...15 {
                            let particle = Particle()
                            particles.append(particle)
                        }
                    }
                }
                .onChange(of: status) { newValue in
                    if !newValue {
                        /// Reset Animation
                        for index in particles.indices {
                            particles[index].reset()
                        }
                    } else {
                        /// Activating Particles
                        for index in particles.indices {
                            /// Random X & Y Calculation Based on Index
                            let total: CGFloat = CGFloat(particles.count)
                            let progress: CGFloat = CGFloat(index) / total
                            
                            let maxX: CGFloat = (progress > 0.5) ? 100 : -100
                            let maxY: CGFloat = 60
                            
                            let randomX: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxX)
                            let randomY: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxY) + 35
                            /// Min Scale = 0.35
                            /// Max Scale = 1
                            let randomScale: CGFloat = .random(in: 0.35...1)
                            
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                /// Extra Random Values For Spreading Particles Across the View
                                let extraRandomX: CGFloat = (progress < 0.5 ? .random(in: 0...10) : .random(in: -10...0))
                                let extraRandomY: CGFloat = .random(in: 0...30)
                                
                                particles[index].randomX = randomX + extraRandomX
                                particles[index].randomY = -randomY - extraRandomY
                            }
                            
                            /// Scaling With Ease Animation
                            withAnimation(.easeInOut(duration: 0.3)) {
                                particles[index].scale = randomScale
                            }
                            
                            /// Removing Particles Based on Index
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)
                                .delay(0.25 + (Double(index) * 0.005))) {
                                    particles[index].scale = 0.001
                            }
                        }
                    }
                }
            }
    }
}
fileprivate struct ParticleModifier2: ViewModifier {
    var systemImage: String
    var font: Font
    var status: Bool
    var activeTint: Color
    var inActiveTint: Color

    @State private var particles: [Particle] = []

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        Image(systemName: systemImage)
                            .font(font)
                            .foregroundColor(status ? activeTint : inActiveTint)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                            .opacity(status ? 1 : 0)
                            .animation(.none, value: status)
                    }
                }
                .onAppear {
                    if particles.isEmpty {
                        for _ in 1...15 {
                            let particle = Particle()
                            particles.append(particle)
                        }
                    }
                }
                .onReceive(Just(status)) { newValue in
                    if newValue {
                        startParticlesAnimation()
                    } else {
                        resetParticlesAnimation()
                    }
                }
            }
    }

    private func startParticlesAnimation() {
        for index in particles.indices {
            let total: CGFloat = CGFloat(particles.count)
            let progress: CGFloat = CGFloat(index) / total

            let maxX: CGFloat = (progress > 0.5) ? 100 : -100
            let maxY: CGFloat = 60

            let randomX: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxX)
            let randomY: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxY) + 35

            let randomScale: CGFloat = .random(in: 0.35...1)

            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                let extraRandomX: CGFloat = (progress < 0.5 ? .random(in: 0...10) : .random(in: -10...0))
                let extraRandomY: CGFloat = .random(in: 0...30)

                particles[index].randomX = randomX + extraRandomX
                particles[index].randomY = -randomY - extraRandomY
            }

            withAnimation(.easeInOut(duration: 0.3)) {
                particles[index].scale = randomScale
            }
        }

        // Schedule the next animation loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if status {
                startParticlesAnimation()
            }
        }
    }

    private func resetParticlesAnimation() {
        for index in particles.indices {
            particles[index].reset()
        }
    }
}

//struct MyPreviewProvider_Previews: PreviewProvider {
//    static var previews: some View {
//        Particle()
//    }
//}
