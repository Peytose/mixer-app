//
//  QRCodeBoxView.swift
//  mixer
//
//  Created by Jose Martinez on 3/21/23.
//

import SwiftUI

struct BoxView: View {
    var cornerRadius: CGFloat
    var color: Color
    var frame: CGSize
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .frame(width: frame.width, height: frame.height)
            .foregroundColor(color)
    }
}
