//
//  LogoView.swift
//  mixer
//
//  Created by Peyton Lyons on 12/21/22.
//

import SwiftUI

struct LogoView: View {
    var frameWidth: CGFloat
    
    var body: some View {
        Image(decorative: "mixer-icon-white")
            .resizable()
            .scaledToFit()
            .frame(width: frameWidth)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(frameWidth: 250)
    }
}
