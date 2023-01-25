//
//  DetailRowView.swift
//  mixer
//
//  Created by Jose Martinez on 1/12/23.
//

import SwiftUI

struct DetailRow: View {
    var image: String
    var text: String
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 21, height: 21)
                .padding(7)
                .background(.ultraThinMaterial)
                .backgroundStyle(cornerRadius: 10, opacity: 0.5)
            
            Text(text)
        }
    }
}
