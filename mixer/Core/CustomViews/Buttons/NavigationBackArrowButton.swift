//
//  NavigationBackArrowButton.swift
//  mixer
//
//  Created by Peyton Lyons on 8/25/23.
//

import SwiftUI

struct NavigationBackArrowButton: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        Button { path.removeLast() } label: {
            Image(systemName: "arrow.left")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
}
