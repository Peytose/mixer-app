//
//  NextButton.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//
import SwiftUI

struct NextButton: View {
    var padding: CGFloat = 90
    var text: String = "Next"
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.mixerPurpleGradient)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.horizontal, padding)
            .shadow(radius: 15)
            .shadow(radius: 5, y: 10)
            .overlay(content: {
                Text(text)
                    .foregroundColor(Color.white)
                    .font(.title2.weight(.semibold))
            })
    }
}
