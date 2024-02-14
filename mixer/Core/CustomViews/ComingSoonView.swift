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
                Group {
                    if #available(iOS 17.0, *) {
                        Image(systemName: "bolt.badge.clock")
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.theme.mixerIndigo, Color.white)
                            .symbolEffect(.pulse,
                                          options: .speed(1).repeat(3),
                                          value: isActive)
                    } else {
                        Image(systemName: "clock.badge.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.white)
                    }
                }
                .frame(width: 80)
                .onAppear {
                    isActive = true
                }
                .onTapGesture {
                    isActive.toggle()
                }
                
                Text("\(Text("Coming ").font(.title).fontWeight(.semibold).foregroundColor(Color.white)) \(Text("soon!").font(.title).fontWeight(.semibold).foregroundColor(Color.theme.mixerIndigo))")
                    
                
                Text("We're working hard to bring you something amazing")
                    .font(.callout)
                    .foregroundColor(Color.secondary)
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
