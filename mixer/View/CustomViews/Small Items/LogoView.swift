//
//  LogoView.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//


import SwiftUI

struct LogoView: View {
    var image: Image
    var padding: CGFloat = 6

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 26, height: 26)
            .cornerRadius(10)
            .padding(padding)
            .background(.ultraThinMaterial)
            .backgroundStyle(cornerRadius: 18, opacity: 0.4)
    }
    
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(image: Image(systemName: "plus"))
    }
}
