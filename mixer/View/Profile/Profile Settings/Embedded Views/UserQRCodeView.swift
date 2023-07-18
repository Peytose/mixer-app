//
//  UserQRCodeView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/6/23.
//

import SwiftUI
import ScreenshotPreventingSwiftUI

struct UserQRCodeView: View {
    let image: Image
    
    var body: some View {
        VStack(alignment: .center) {
            image
                .foregroundColor(.white)
                .screenshotProtected(isProtected: true)
        }
        .background(Color.mixerBackground)
        .ignoresSafeArea()
    }
}

//struct UserQRCodeView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserQRCodeView()
//    }
//}
