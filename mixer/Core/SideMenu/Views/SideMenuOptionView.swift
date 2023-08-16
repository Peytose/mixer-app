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
        HStack(spacing: 16) {
            Image(systemName: option.imageName)
                .font(.title2)
                .imageScale(.medium)
            
            Text(option.title)
                .font(.headline)
            
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
