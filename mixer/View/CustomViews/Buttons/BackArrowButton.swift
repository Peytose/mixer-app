//
//  BackArrowButton.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//

import SwiftUI

struct BackArrowButton: View {
    var body: some View {
        Image(systemName: "arrow.left")
            .foregroundColor(.white)
            .font(.title2)
            .shadow(radius: 10)
        
    }
}

struct BackArrowButton_Previews: PreviewProvider {
    static var previews: some View {
        BackArrowButton()
            .preferredColorScheme(.dark)
    }
}
