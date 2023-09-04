//
//  MixerIdView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/6/23.
//

import SwiftUI
import ScreenshotPreventingSwiftUI
import MaterialUI
import Kingfisher

struct Ripple: ViewModifier {
    // MARK: Internal
    @Binding var location: CGPoint
    let color: Color
    var onTap: (() -> Void)? = nil

    @State private var scale: CGFloat = 0.01
    
    @State private var animationPosition: CGFloat = 0.0
    @State private var x: CGFloat = 0.0
    @State private var y: CGFloat = 0.0
    
    @State private var opacityFraction: CGFloat = 0.0
    
    let timeInterval: TimeInterval = 0.5
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                content
                
                Circle()
                    .foregroundColor(color)
                    .opacity(0.4*opacityFraction)
                    .scaleEffect(scale)
                    .offset(x: x, y: y)
            }
            .onTapGesture { location in
                // This directly gives the absolute CGPoint of the tap
                let absoluteTapLocation = location

                // Calculate the relative tap location with respect to the view size
                self.location = CGPoint(x: absoluteTapLocation.x / geometry.size.width,
                                        y: absoluteTapLocation.y / geometry.size.height)
                x = absoluteTapLocation.x - geometry.size.width / 2
                y = absoluteTapLocation.y - geometry.size.height / 2
                opacityFraction = 1.0

                withAnimation(.linear(duration: timeInterval)) {
                    onTap?()
                    scale = 3.0 * (max(geometry.size.height, geometry.size.width) / min(geometry.size.height, geometry.size.width))
                    opacityFraction = 0.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                        scale = 1.0
                        opacityFraction = 0.0
                    }
                }
            }
            .clipped()
        }
    }
}

extension View {
    func rippleEffect(location: Binding<CGPoint>,
                      rippleColor: Color = .accentColor.opacity(0.5),
                      onTap: (() -> Void)? = nil) -> some View {
        modifier(Ripple(location: location, color: rippleColor, onTap: onTap))
    }
}

struct MixerIdView: View {
    let user: User
    let image: Image
    @State private var tapLocation: CGPoint = .zero
    @State private var gradientColors: [Color] = [Color.pink, Color.purple]
    @State private var rippleColor: Color = Color.black.opacity(0.5)
    
    let gradientPairs: [[Color]] = [
        [Color.red, Color.orange],
        [Color.cyan, Color.blue],
        [Color.pink, Color.purple],
        [Color.mint, Color.green]
    ]

    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: gradientColors),
                           center: .init(x: tapLocation.x, y: tapLocation.y),
                           startRadius: 1,
                           endRadius: 200)
            .rippleEffect(location: $tapLocation, rippleColor: rippleColor) {
                gradientColors = gradientPairs.randomElement() ?? gradientPairs[0]
                
                // Use UIColor conversion to get the RGB components
                if let components = UIColor(gradientColors[0]).cgColor.components, components.count >= 3 {
                    let averageColorValue = (components[0] + components[1] + components[2]) / 3.0
                    rippleColor = averageColorValue < 0.5 ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
                }
            }
            .ignoresSafeArea(.all)
            
            VStack {
                VStack(alignment: .center, spacing: 0) {
                    KFImage(URL(string: user.profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .padding(8)
                        .background {
                            Circle()
                                .foregroundColor(Color.theme.secondaryBackgroundColor)
                        }
                    
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    image
                        .cornerRadius(30)
                        .scaleEffect(0.85)
                }
                .padding(.top, -40)
                .background {
                    Color.theme.secondaryBackgroundColor
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                .padding(.top, 130)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
                    .shadow(color: .black, radius: 2)
            }
        }
    }
}
