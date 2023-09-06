//
//  Ripple.swift
//  mixer
//
//  Created by Peyton Lyons on 9/5/23.
//

import SwiftUI

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
