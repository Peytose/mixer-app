//
//  StretchableHeaderView.swift
//  mixer
//
//  Created by Jose Martinez on 1/12/23.
//

import SwiftUI

struct StretchableHeader: View {
    let imageName: String
    
    var body: some View {
        GeometryReader { geometry in
            Image(self.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width,
                       height: geometry.height)
                .offset(y: geometry.verticalOffset)
        }
        .frame(height: 350)
    }
}

extension GeometryProxy {
    private var offset: CGFloat {
        frame(in: .global).minY
    }
    var height: CGFloat {
        size.height + (offset > 0 ? offset : 0)
    }
    
    var verticalOffset: CGFloat {
        offset > 0 ? -offset : 0
    }
}
