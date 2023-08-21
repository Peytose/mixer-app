//
//  QRCodeAnimationView.swift
//  mixer
//
//  Created by Jose Martinez on 3/21/23.
//

import SwiftUI

struct QRCodeAnimationView: View {
    @State var qrOverlayOffsetY: CGFloat = 0
    @State var qrOverlayScale: CGFloat = 100

    var body: some View {
        ZStack {
            qrView
                .offset(y: -80)

            VStack {
                Spacer()
                
                Text("Fast and reliable check in")
                    .font(.system(size: 40).weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 370, height: 100, alignment: .center)
            }
            .padding()
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 40)
        .padding(.top, 30)
    }
    
    var qrView: some View {
        VStack {
            
        }
        .frame(width: 200, height: 200)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.theme.mixerIndigo, lineWidth: 4)
        )
        .overlay(
            BoxView(cornerRadius: 4, color: Color.theme.backgroundColor, frame: CGSize(width:100, height: 220))
        )
        .overlay(
            BoxView(cornerRadius: 4, color: Color.theme.backgroundColor, frame: CGSize(width:220, height: 100))
        )
        .overlay(
            Image("qrcode")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 170, height: 170)
            
        )
        .overlay(
            BoxView(cornerRadius: 2, color: Color.theme.mixerIndigo, frame: CGSize(width: 220, height: 2))
                .scaleEffect(y: qrOverlayScale)
                .shadow(color: .pink, radius: 12, x: 0, y: 0)
                .offset(y: qrOverlayOffsetY)
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 0.5)) {
                        qrOverlayScale = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            qrOverlayOffsetY = -80
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            qrOverlayOffsetY = 80
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            qrOverlayOffsetY = 0
                        }
                    }
                }
            ,alignment: .center
        )
        .frame(width: UIScreen.iPhoneViewWidth, height: UIScreen.iPhoneViewHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 38)
                .stroke(.black)
        )
        .overlay(
            CustomRoundedCornerView(color: Color.theme.secondaryBackgroundColor, tl: 0, tr: 0, bl: 14, br: 14)
                .frame(width: UIScreen.main.bounds.width / 2.5, height: 24),
            alignment: .top)
    }
}

struct QRCodeAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeAnimationView()
            .preferredColorScheme(.dark)
    }
}
