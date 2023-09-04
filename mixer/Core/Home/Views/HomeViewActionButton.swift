//
//  HomeViewActionButton.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI

struct HomeViewActionButton: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button {
            homeViewModel.actionForState()
        } label: {
            Image(systemName: homeViewModel.iconForState())
                .font(.title2)
                .foregroundColor(.black)
                .padding()
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black, radius: 6)
        }
        .offset(x: homeViewModel.showSideMenu ? DeviceTypes.ScreenSize.width * 0.8 : 0)
        .padding(.leading)
        .padding(.top, 4)
        .frame(maxWidth: DeviceTypes.ScreenSize.width,
               maxHeight: DeviceTypes.ScreenSize.height,
               alignment: .topLeading)
    }
}

struct HomeViewActionButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewActionButton()
    }
}
