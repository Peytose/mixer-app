//
//  CharactersRemainView.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI

struct CharactersRemainView: View {
    let valueName: String
    var currentCount: Int
    var limit: Int = 100
    
    var body: some View {
        Text("\(valueName): ")
            .font(.callout)
            .foregroundColor(.secondary)
        +
        Text("\(limit - currentCount)")
            .bold()
            .font(.callout)
            .foregroundColor(currentCount <= limit ? .mixerIndigo : Color(.systemPink))
        +
        Text(" characters remain")
            .font(.callout)
            .foregroundColor(.secondary)
    }
}

struct CharactersRemainView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersRemainView(valueName: "Bio", currentCount: 69)
    }
}
