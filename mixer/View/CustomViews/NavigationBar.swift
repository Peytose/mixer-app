//
//  NavigationBar.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI

struct NavigationBar: View {
    @EnvironmentObject var model: Model
    var title = "Explore"
    var onSocialPage: Bool = true
    @Binding var contentHasScrolled: Bool
    @Binding var showNavigationBar: Bool
    var showLocation = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .frame(maxHeight: .infinity, alignment: .top)
                .blur(radius: contentHasScrolled ? 10 : 0)
                .padding(-20)
                .opacity(contentHasScrolled ? 1 : 0)
            
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .animatableFont(size: contentHasScrolled ? 22 : 34, weight: .bold)
                    .foregroundStyle(.primary)
                    .padding(.top, 20)
                    .opacity(contentHasScrolled ? 0.7 : 1)
                
                Spacer()

                Image("mock-user-1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

            }
            .padding(.horizontal, 20)
            .overlay {
                HStack(alignment: .center) {
                    Image(systemName: "mappin.and.ellipse")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.primary, Color.blue)
                    
                    
                    Text("Boston, MA")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .opacity(contentHasScrolled ? 0.7 : 1)
                }
                .padding(.top, 20)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        }
        .offset(y: showNavigationBar ? 0 : -120)
        .offset(y: contentHasScrolled ? -16 : 0)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(contentHasScrolled: .constant(false), showNavigationBar: .constant(true))
            .environmentObject(Model())
            .preferredColorScheme(.dark)
    }
}
