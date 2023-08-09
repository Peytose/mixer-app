//
//  NextButton.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//
import SwiftUI

struct NextButton: View {
    var text: String = "Next"
    @State private var progress: CGFloat = 0
    let gradient1 = Gradient(colors: [Color.theme.mixerPurple, Color.theme.mixerPurple])
    let gradient2 = Gradient(colors: [Color.theme.mixerIndigo, Color.theme.mixerIndigo])
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .animatableGradient(fromGradient: gradient1,
                                        toGradient: gradient2,
                                        progress: progress)
                    .frame(height: 75)
                    .mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(radius: 10)
                    .allowsHitTesting(false)
                    .onAppear {
                        withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                            self.progress = 1.0
                        }
                    }
                
                Text(text)
                    .foregroundColor(Color.white)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
    }
}
