//
//  BackArrowButton.swift
//  mixer
//
//  Created by Peyton Lyons on 2/23/24.
//

import SwiftUI

struct BackArrowButton: View {
    let action: () -> Void
    
    var body: some View {
        Button { action() } label: {
            Image(systemName: "arrow.left")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
}
