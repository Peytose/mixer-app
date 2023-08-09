//
//  MixerIdView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/6/23.
//

import SwiftUI
import ScreenshotPreventingSwiftUI

struct MixerIdView: View {
    let user: User
    let image: Image
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 10) {
                image
                    .scaleEffect(0.85)
                
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
        }
        .navigationBar(title: "mixer ID", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackArrowButton()
            }
        }
    }
}
