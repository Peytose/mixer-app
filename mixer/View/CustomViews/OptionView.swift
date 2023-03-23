//
//  OptionView.swift
//  mixer
//
//  Created by Peyton Lyons on 3/16/23.
//

import SwiftUI

struct OptionView: View {
    @Binding var boolean: Bool
    let text: String
    let subtext: String
    let isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Button { boolean.toggle() } label: {
                    if isEnabled {
                        Image(systemName: boolean ? "circle.fill" : "circle.dashed")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(boolean ? .white : .secondary)
                            .frame(width: 28)
                    } else {
                        Image(systemName: "circle.slash")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary.opacity(0.75))
                            .frame(width: 28)
                    }
                }
                .disabled(!isEnabled)
                
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(isEnabled ? .white : .secondary.opacity(0.75))
                
                Spacer()
            }
            
            Text(subtext)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView(boolean: .constant(false),
                   text: "Text",
                   subtext: "Subtext",
                   isEnabled: true)
    }
}
