//
//  InfoButton.swift
//  mixer
//
//  Created by Jose Martinez on 5/16/23.
//

import SwiftUI

struct InfoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .font(.body)
                .foregroundColor(Color.theme.mixerIndigo)
        }
    }
}

struct InfoButton_Previews: PreviewProvider {
    static var previews: some View {
        InfoButton() {}
            .preferredColorScheme(.dark)
    }
}
