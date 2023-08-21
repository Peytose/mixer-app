//
//  SideMenuOptionView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI

struct SideMenuOptionView<Option: MenuOption>: View {
    let option: Option
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: option.imageName)
                .font(.title2)
                .imageScale(.medium)
                .frame(width: 24)
            
            Text(option.title)
                .font(.headline)
                .frame(alignment: .leading)
            
            Spacer()
        }
        .foregroundColor(.white)
    }
}

struct SideMenuOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuOptionView(option: SideMenuOption.settings)
    }
}
