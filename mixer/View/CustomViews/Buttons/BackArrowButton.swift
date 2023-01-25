//
//  BackArrowButton.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//

import SwiftUI

struct BackArrowButton: View {
    var body: some View {
        Image(systemName: "arrow.left")
            .foregroundColor(Color.mainFont)
            .font(.system(size: 24))
            .shadow(radius: 10)
    }
}

struct BackArrowButton_Previews: PreviewProvider {
    static var previews: some View {
        BackArrowButton()
    }
}
