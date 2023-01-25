//
//  CustomStickyHeader.swift
//  mixer
//
//  Created by Jose Martinez on 12/20/22.
//

//
//  CustomStickyStackView.swift
//  mixer
//
//  Created by Jose Martinez on 11/13/22.
//

import SwiftUI

struct CustomStickyStackView<Title: View,Content: View>: View {
    var titleView: Title
    var contentView: Content
    
    // Offsets...
    @State var topOffset: CGFloat = 0
    @State var bottomOffset: CGFloat = 0
    
    init(@ViewBuilder titleView: @escaping ()->Title,@ViewBuilder contentView: @escaping ()->Content){
        
        self.contentView = contentView()
        self.titleView = titleView()
    }
    
    var body: some View {
        HStack(spacing: 0){
            titleView
                .font(.callout)
                .lineLimit(1)
                .frame(width: 40, alignment: .topLeading)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 6)
                .background(Color.mixerBackground)
                .zIndex(1)
            
            VStack {
                contentView
//                    .padding(.horizontal, 10)
                    .padding(.trailing, 6)
                    .padding(.vertical, 5)
            }
            .background(Color.mixerBackground)
            // Moving Content Upward....
            .offset(y: topOffset >= 120 ? 0 : -(-topOffset + 120))
            .zIndex(0)
            // Clipping to avoid backgroung overlay
            .clipped()
            .opacity(getOpacity())
        }
        .colorScheme(.dark)
        .cornerRadius(12)
        .opacity(getOpacity())
        // Stopping View @120....
        .offset(y: topOffset >= 120 ? 0 : -topOffset + 120)
        .background(
            GeometryReader{proxy -> Color in
            
            let minY = proxy.frame(in: .global).minY
            let maxY = proxy.frame(in: .global).maxY
            
            DispatchQueue.main.async {
                self.topOffset = minY
                // reducing 120...
                self.bottomOffset = maxY - 120
                // thus we will get our title height 38.....
            }
            return Color.clear
            }
        )
    }
    
    // opacity...
    func getOpacity()->CGFloat{
        
        if bottomOffset < 28{
            
            let progress = bottomOffset / 28
            
            return progress
        }
        return 1
    }
}
