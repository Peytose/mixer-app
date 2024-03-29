//
//  LoadingView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/18/23.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.theme.secondaryBackgroundColor
                .opacity(0.9)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                .scaleEffect(2)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
