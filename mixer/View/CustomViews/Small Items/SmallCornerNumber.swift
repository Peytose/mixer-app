//
//  IconBadge.swift
//  mixer
//
//  Created by Peyton Lyons on 4/14/23.
//

import SwiftUI

struct IconBadge: View {
    let count: Int
    
    var body: some View {
        if count > 0 {
            ZStack {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                Text("\(min(count, 99))")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
    }
}

struct IconBadge_Previews: PreviewProvider {
    static var previews: some View {
        IconBadge(count: 99)
    }
}
