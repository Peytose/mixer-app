//
//  LandingPageView.swift
//  mixer
//
//  Created by Jose Martinez on 3/20/23.
//

import Foundation
import SwiftUI

struct LandingPageView: View {
    
    init() {
       UIPageControl.appearance().currentPageIndicatorTintColor = .red
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.8)
           }
    
    @State var selectedPage = 0
    var body: some View {
        
        // Main Stack
       
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            
            if (selectedPage == 0)
            {
                Image("screen")
                    .resizable()
                    .opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                Image("gradient")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                   
            }
            
            
            
            VStack{
          
                
                ZStack{
                TabView(selection: $selectedPage)
                {
                    ForEach(0..<testData.count){
                        index in CardView(card : testData[index]).tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                }.offset(x: 0, y: 20)
                
             
                
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 380, height: 75)
                        .foregroundColor(Color("buttonbg"))
                        .padding(20)
                    
                    Text("SIGN IN")
                        .fontWeight(.regular)
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .shadow(color: .gray, radius: 1, x: 1, y: 1)
                        
                }
            }
            
            if (selectedPage == 1){
               TopNav()
            }
            if (selectedPage == 2){
                TopNav()
            }
            if (selectedPage == 3){
                TopNav()
            }
        }
       
    }
}

struct TopNav: View {
    var body: some View {
        ZStack{
            HStack{
                Image("netflixlogo")
                    .resizable()
                    .frame(width: 110, height: 62)
                
                Spacer()
                
                Text("Help")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                Spacer().frame(width : 10)
                   
                
                Text("Privacy")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                 
            }
            .offset(x: 0, y: -395)
            .padding()
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}
