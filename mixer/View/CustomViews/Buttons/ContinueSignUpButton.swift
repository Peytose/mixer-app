//
//  ContinueSignUpButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/17/22.
//

import SwiftUI

struct ContinueSignUpButton: View {
    let text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.DesignCodeWhite)
                .frame(width: 250, height: 50)
                .shadow(radius: 20, x: -8, y: -8)
                .shadow(radius: 20, x: 8, y: 8)
                .overlay {
                    Text(text)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.black)
                }
        }
    }
}
