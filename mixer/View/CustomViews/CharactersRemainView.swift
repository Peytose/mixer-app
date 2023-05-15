//
//  CharactersRemainView.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI

struct CharactersRemainView: View {
    var currentCount: Int
    var limit: Int = 100
    
    var body: some View {
        Text("\(limit - currentCount)")
            .font(.callout.weight(.bold))
            .foregroundColor(currentCount <= limit ? .mixerIndigo : Color(.systemPink))
        +
        Text(" characters remain")
            .font(.callout)
            .foregroundColor(.secondary)
    }
}

struct CharactersRemainView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersRemainView(currentCount: 69)
    }
}
