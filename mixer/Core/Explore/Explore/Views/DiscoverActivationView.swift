//
//  DiscoverActivationView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/31/23.
//

import SwiftUI

struct DiscoverActivationView: View {
    @State private var index   = 0
    @State private var animate = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image("mixer-icon-white")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color.theme.mixerIndigo)
                .frame(width: 36, height: 36)
                .padding(.leading)
            
            Text("Party, event, or meet-up? Search away...")
                .font(.callout)
                .foregroundColor(Color(.darkGray))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width - 64, height: 50)
        .background(
            Rectangle()
                .fill(Color.white)
                .cornerRadius(10)
                .shadow(color: .black, radius: 6)
        )
    }
}

struct DiscoverActivationView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverActivationView()
    }
}
