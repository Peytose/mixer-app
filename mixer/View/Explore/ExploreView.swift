//
//  ExploreView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()

            Text("Explore View")
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
