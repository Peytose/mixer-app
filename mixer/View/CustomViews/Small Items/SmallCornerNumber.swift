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
            if count > 99 {
                Text("99+")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background {
                        Circle()
                            .foregroundColor(.red)
                            .frame(maxWidth: 26, maxHeight: 26)
                    }
            } else {
                Text("\(count)")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background {
                        Circle()
                            .foregroundColor(.red)
                            .frame(maxWidth: 20, maxHeight: 20)
                    }
            }
        }
    }
}

struct IconBadge_Previews: PreviewProvider {
    static var previews: some View {
        IconBadge(count: 99)
    }
}
