//
//  CardView.swift
//  mixer
//
//  Created by Jose Martinez on 3/20/23.
//

import SwiftUI

struct LaunchScreenCardView: View {
    var screen : LaunchScreenCard
    
    var body: some View {
        ZStack {
            Image(screen.image)
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 260)
                .offset(y: -10)
            
            VStack {
                Spacer()
                
                Text(screen.title)
                    .font(.system(size: 40).weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 370, height: 100, alignment: .center)
            }
            .padding()
            .padding(.bottom, 50)
        }
    }
}

struct LaunchScreenCardView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenCardView(screen: screens[2])
            .preferredColorScheme(.dark)
    }
}
