//
//  QRCodeScannerView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/11/23.
//

import SwiftUI
import CodeScanner

struct QRCodeScannerView: View {
    @Binding var isShowingQRCodeScanView: Bool
    @Binding var isTorchOn: Bool
    let completion: (Result<ScanResult, ScanError>) -> Void
    
    var body: some View {
        ZStack {
            CodeScannerView(codeTypes: [.qr],
                            scanMode: .oncePerCode,
                            manualSelect: false,
                            showViewfinder: true,
                            shouldVibrateOnSuccess: true,
                            isTorchOn: isTorchOn,
                            completion: completion)
            .ignoresSafeArea()
            
            XDismissButton { isShowingQRCodeScanView = false }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding([.leading, .top])
            
            Button { isTorchOn.toggle() } label: {
                Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isTorchOn ? Color.theme.mixerIndigo : .white)
                    .frame(width: 40, height: 40)
                    .padding()
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 100)
        }
        .preferredColorScheme(isTorchOn ? .light : .dark)
    }
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView(isShowingQRCodeScanView: .constant(false),
                          isTorchOn: .constant(false)) { _ in }
    }
}
