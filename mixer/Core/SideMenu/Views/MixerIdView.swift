//
//  MixerIdView.swift
//  mixer
//
//  Created by Peyton Lyons on 7/6/23.
//

import SwiftUI
import ScreenshotPreventingSwiftUI
import MaterialUI
import Kingfisher

struct MixerIdView: View {
    let user: User
    let image: Image
    @State private var tapLocation: CGPoint = .zero
    @State private var gradientColors: [Color] = [Color.pink, Color.purple]
    @State private var rippleColor: Color = Color.black.opacity(0.5)
    
    let gradientPairs: [[Color]] = [
        [Color.red, Color.orange],
        [Color.cyan, Color.blue],
        [Color.pink, Color.purple],
        [Color.mint, Color.green]
    ]
    
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: gradientColors),
                           center: .init(x: tapLocation.x, y: tapLocation.y),
                           startRadius: 1,
                           endRadius: 200)
            .rippleEffect(location: $tapLocation, rippleColor: rippleColor) {
                gradientColors = gradientPairs.randomElement() ?? gradientPairs[0]
                
                // Use UIColor conversion to get the RGB components
                if let components = UIColor(gradientColors[0]).cgColor.components, components.count >= 3 {
                    let averageColorValue = (components[0] + components[1] + components[2]) / 3.0
                    rippleColor = averageColorValue < 0.5 ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
                }
            }
            .ignoresSafeArea(.all)
            
            VStack {
                VStack(alignment: .center, spacing: 0) {
                    KFImage(URL(string: user.profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .padding(8)
                        .background {
                            Circle()
                                .foregroundColor(Color.theme.secondaryBackgroundColor)
                        }
                    
                    VStack {
                        Text(user.firstName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    image
                        .cornerRadius(30)
                        .scaleEffect(0.85)
                }
                .padding(.top, -40)
                .background {
                    Color.theme.secondaryBackgroundColor
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                .padding(.top, 130)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                PresentationBackArrowButton()
                    .shadow(color: .black, radius: 2)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "https://rococo-gumdrop-0f32da.netlify.app") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(6)
                        .background(.white)
                        .clipShape(Circle())
                }
            }
        }
    }
}

