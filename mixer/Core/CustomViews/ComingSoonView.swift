//
//  ComingSoonView.swift
//  mixer
//
//  Created by Peyton Lyons on 12/10/23.
//

import SwiftUI

struct ComingSoonView: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "bolt.badge.clock")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.theme.mixerIndigo, Color.white)
                    .frame(width: 80)
                    .modify {
                        if #available(iOS 17.0, *) {
                            $0.symbolEffect(.pulse,
                                            options: .speed(1).repeat(3),
                                            value: isActive)
                        }
                    }
                    .onAppear {
                        isActive = true
                    }
                    .onTapGesture {
                        isActive.toggle()
                    }
                    
                
                Text("Coming soon!")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                
                Text("We're working hard to bring you something amazing")
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: DeviceTypes.ScreenSize.width * 0.85,
                   height: DeviceTypes.ScreenSize.height,
                   alignment: .top)
            .padding(.top, DeviceTypes.ScreenSize.height * 0.33)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                PresentationBackArrowButton()
            }
        }
    }
}

#Preview {
    ComingSoonView()
}
