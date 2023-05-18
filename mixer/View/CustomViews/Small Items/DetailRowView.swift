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
                .frame(width: 20, height: 20)
                .padding(6)
                .background(.ultraThinMaterial)
                .backgroundStyle(cornerRadius: 10, opacity: 0.5)
            
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .fontWeight(.medium)
        }
    }
}

struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(image: "heart", text: "Testing")
    }
}
