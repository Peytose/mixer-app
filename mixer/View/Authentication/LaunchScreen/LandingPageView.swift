//
//  LaunchPageView.swift
//  mixer
//
//  Created by Jose Martinez on 3/20/23.
//

import Foundation
import SwiftUI

struct LaunchPageView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State var selectedPage = 0
    @State var showAuthFlow = false
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.mixerIndigo)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    TabView(selection: $selectedPage.animation())
                    {
                        ForEach(0..<screens.count) { index in
                            if index == 4 {
                                QRCodeAnimationView()
                            } else {
                                LaunchScreenCardView(screen: screens[index]).tag(index)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .onChange(of: selectedPage) { newValue in
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                }
                .offset(y: -10)
                
                if selectedPage == 4 {
                    Capsule()
                        .fill(Color.mixerIndigo)
                        .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                        .shadow(radius: 20, x: -8, y: -8)
                        .shadow(radius: 20, x: 8, y: 8)
                        .overlay {
                            Text("Get Started")
                                .font(.body.weight(.medium))
                                .foregroundColor(.white)
                        }
                        .offset(y: -20)
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation() {
                                showAuthFlow.toggle()
                            }
                            
                            Button("Show keyboard") {
                                UIApplication.shared.windows.first?.rootViewController?.view.endEditing(false)
                                UITextField.appearance().becomeFirstResponder()
                            }
                        }
                } else {
                    Capsule()
                        .stroke(lineWidth: 2)
                        .fill(Color.mixerIndigo.opacity(0.4))
                        .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
                        .shadow(radius: 20, x: -8, y: -8)
                        .shadow(radius: 20, x: 8, y: 8)
                        .overlay {
                            Text("Skip")
                                .font(.body.weight(.medium))
                                .foregroundColor(.white)
                        }
                        .offset(y: -20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation() {
                                selectedPage = 4
                            }
                        }
                }

            }
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .top) {
            Text("mixer.")
                .font(.title.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .fullScreenCover(isPresented: $showAuthFlow) {
            AuthFlow()
        }
    }
}

struct LaunchPageView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchPageView()
            .environmentObject(AuthViewModel())
    }
}
