//
//  SocialPageNavigationBar.swift
//  mixer
//
//  Created by Jose Martinez on 12/28/22.
//

//
//  NavigationBar.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI

struct SocialPageNavigationBar: View {
    @EnvironmentObject var model: Model
    var location = "Boston, MA"
    var onSocialPage: Bool = true
    @Binding var contentHasScrolled: Bool
    @Binding var showNavigationBar: Bool
    @State var isRefreshing = false
    var showLocation = false
    
    var body: some View {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .backgroundColor(opacity: 0.5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity, alignment: .top)
                    .blur(radius: contentHasScrolled ? 10 : 0)
                    .padding(-20)
                    .opacity(contentHasScrolled ? 1 : 0)
                
                HStack(alignment: .center, spacing: 0) {
                    //                Text(title)
                    //                    .animatableFont(size: contentHasScrolled ? 22 : 34, weight: .bold)
                    //                    .foregroundStyle(.primary)
                    //                    .padding(.top, 20)
                    //                    .opacity(contentHasScrolled ? 0.7 : 1)
                    NavigationLink(destination: UserProfilePrototypeView()) {
                        Image("mock-user-1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .backgroundColor(opacity: 0.4)
                                    .clipShape(Circle())
        //                            .frame(width: 75, height: 75)
                            )
                    }

                    Spacer()
                    
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.9))
                        .backgroundColor(opacity: 0.4)
                        .backgroundBlur(radius: 10)
                        .frame(width: 155, height: 35)
                        .clipShape(Capsule())
                        .overlay(
                            HStack(alignment: .center) {
                                Image(systemName: "mappin.and.ellipse")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color.primary, Color.blue)
                                
                                
                                Text(location)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .opacity(contentHasScrolled ? 0.7 : 1)
                            }
                        )
                        
                                    
                    Spacer()
                    
                    Circle()
                        .fill(.ultraThinMaterial.opacity(0.9))
                        .backgroundColor(opacity: 0.4)
                        .backgroundBlur(radius: 10)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .imageScale(.large)
                                .fontWeight(.medium)
                        }
                        .rotationEffect(Angle(degrees: isRefreshing ? 720 : 0))
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            
                            withAnimation(.spring(response: 2.2)) {
                                isRefreshing.toggle()

                            }
                        }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .offset(y: showNavigationBar ? -5 : -120)
//        .offset(y: contentHasScrolled ? -16 : 0)
    }
}

struct SocialPageNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        SocialPageNavigationBar(contentHasScrolled: .constant(false), showNavigationBar: .constant(true))
            .environmentObject(Model())
            .preferredColorScheme(.dark)
    }
}
