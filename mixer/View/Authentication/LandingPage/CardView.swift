//
//  CardView.swift
//  mixer
//
//  Created by Jose Martinez on 3/20/23.
//

import SwiftUI

struct CardView: View {
    var card : Card
    
    var body: some View {
        ZStack {
            Image(card.image)
                .resizable()
                .scaledToFill()
                .frame(width: 320, height: 320)
                .offset(y: -50)
            
            VStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 400, height: 400)

                    .mask(Color.profileGradient) // mask the blurred image using the gradient's alpha values

                
                Text(card.title)
                    .font(.system(size: 40).weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        
        
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: testData[0])
            .preferredColorScheme(.dark)
    }
}
