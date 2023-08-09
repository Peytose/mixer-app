//
//  BackArrowButton.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//

import SwiftUI

struct BackArrowButton: View {
    @Environment (\.dismiss) private var dismiss
    
    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "arrow.left")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
}

struct BackArrowButton_Previews: PreviewProvider {
    static var previews: some View {
        BackArrowButton()
            .preferredColorScheme(.dark)
    }
}
