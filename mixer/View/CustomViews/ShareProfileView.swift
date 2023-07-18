//
//  ShareProfileView.swift
//  mixer
//
//  Created by Jose Martinez on 4/5/23.
//

import SwiftUI
import MessageUI

struct ShareProfileView: View {
    @State private var progress: CGFloat = 0
    let gradient1 = Gradient(colors: [Color.mixerIndigo, .red])
    let gradient2 = Gradient(colors: [.blue, Color.mixerPurple])
    @Environment(\.presentationMode) var mode
    @State var showCopyAlert = false
    
    let link = URL(string: "https://www.mixer.llc")!
    private let pastboard = UIPasteboard.general

    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ProfileQRCodeView()
                
                Text("@joseMartinez")
                    .font(.title)
                
                HStack {
                    ShareLink(item: link) {
                        ButtonView(icon: "square.and.arrow.up", text: "Share Profile", link: link)
                    }
                    
                     Spacer()
                    
                    Button {
                        pastboard.url = link
                        showCopyAlert.toggle()
                    } label: {
                        ButtonView(icon: "link", text: "Copy Link", link: link)
                    }
                    .alert("Copied to clipboard", isPresented: $showCopyAlert, actions: {}) // 4
                    
                }
                .offset(y: 50)
            }
            .frame(maxHeight: .infinity)
            .frame(width: DeviceTypes.ScreenSize.width * 0.75)
            .preferredColorScheme(.dark)
        }
        .overlay(alignment: .top) {
            LogoView(frameWidth: 75)
                .animatableGradient(fromGradient: gradient1,
                                    toGradient: gradient2,
                                    progress: progress)
                .frame(height: 60)
                .mask(LogoView(frameWidth: 75))
                .shadow(radius: 10)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                        self.progress = 1.0
                    }
                }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { mode.wrappedValue.dismiss() }) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title.weight(.semibold))
                    .foregroundColor(.mainFont)
            }
            .padding()
        }
        .overlay(alignment: .topLeading) {
            Button(action: { mode.wrappedValue.dismiss() }) {
                XDismissButton()
            }
            .padding()
    }
    }
}

struct ShareProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ShareProfileView()
    }
}

fileprivate struct ProfileQRCodeView: View {
    @State var qrOverlayOffsetY: CGFloat = 0
    @State var qrOverlayScale: CGFloat = 100

    var body: some View {
        ZStack {
            qrView
        }
    }
    
    var qrView: some View {
        VStack {
        }
        .frame(width: DeviceTypes.ScreenSize.width * 0.75, height: DeviceTypes.ScreenSize.width * 0.75)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.mixerIndigo, lineWidth: 4)
        )
        .overlay(
            BoxView(cornerRadius: 4, color: Color.mixerBackground, frame: CGSize(width: 200, height: DeviceTypes.ScreenSize.width * 0.85))
        )
        .overlay(
            BoxView(cornerRadius: 4, color: Color.mixerBackground, frame: CGSize(width: DeviceTypes.ScreenSize.width * 0.85, height: 200))
        )
        .overlay(
            Image("qrcode")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 250, height: 259)
        )
        .padding(.bottom)
    }
}

fileprivate struct ButtonView: View {
    let icon: String
    let text: String
    var link: URL
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 2)
            .foregroundColor(Color.mixerIndigo)
            .frame(width: 120, height: 70)
            .overlay {
                VStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.mainFont)
                    
                    Text(text)
                        .font(.footnote)
                        .foregroundColor(.mainFont)
                }
            }
    }
}
