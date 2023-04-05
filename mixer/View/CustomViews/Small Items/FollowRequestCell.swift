//
//  FollowRequestCell.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI

struct FollowRequestCell: View {

    var body: some View {
        HStack {
            Image("mock-user-2")
                .resizable()
                .scaledToFill()
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .padding(.trailing, 5)
            
            VStack(alignment: .leading) {
                Text("vijayDey")
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("started following you. \(Text("7h").foregroundColor(.secondary))")
                    .lineLimit(2)
            }
            .font(.subheadline)
            .minimumScaleFactor(0.9)
            
            Spacer()
            
            Actionbutton(text: "Accept", color: Color.mixerIndigo)
                .padding(.leading, 20)
            
            Actionbutton(text: "Reject", color: Color.mixerSecondaryBackground)
        }
        .frame(maxHeight: 60)
    }
}

struct FollowRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        FollowRequestCell()
            .preferredColorScheme(.dark)
    }
}

fileprivate struct Actionbutton: View {
    let text: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 70, height: 30)
                .overlay {
                    Text(text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
        }
    }
}
