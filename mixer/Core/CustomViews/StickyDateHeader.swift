//
//  StickyDateHeader.swift
//  mixer
//
//  Created by Jose Martinez on 12/20/22.
//

import SwiftUI

//struct StickyDateHeader<Header: View, Content: View>: View {
//    var headerView: Header
//    var contentView: Content
//    
//    // Offsets...
//    @State var topOffset: CGFloat = 0
//    @State var bottomOffset: CGFloat = 0
//    
//    init(@ViewBuilder headerView:
//         @escaping () -> Header,
//         @ViewBuilder contentView: @escaping () -> Content) {
//        self.headerView = headerView()
//        self.contentView = contentView()
//    }
//    
//    var body: some View {
//        HStack(spacing: 0){
//            headerView
//                .font(.callout)
//                .frame(width: 40, alignment: .topLeading)
//                .frame(maxHeight: .infinity)
//                .padding(.horizontal, 6)
//                .background(Color.theme.backgroundColor)
//                .zIndex(1)
//            
//            VStack {
//                contentView
//                    .padding(.trailing, 6)
//                    .padding(.vertical, 5)
//                
//                Divider()
//            }
//            .background(Color.theme.backgroundColor)
//            // Moving Content Upward....
//            .offset(y: topOffset >= 120 ? 0 : -(-topOffset + 120))
//            .zIndex(0)
//            // Clipping to avoid backgroung overlay
//            .clipped()
//            .opacity(getOpacity())
//        }
//        .colorScheme(.dark)
//        .cornerRadius(12)
//        .opacity(getOpacity())
//        // Stopping View @120....
//        .offset(y: topOffset >= 120 ? 0 : -topOffset + 120)
//        .background(
//            GeometryReader{proxy -> Color in
//
//                let minY = proxy.frame(in: .global).minY
//                let maxY = proxy.frame(in: .global).maxY
//                
//                DispatchQueue.main.async {
//                    self.topOffset = minY
//                    // reducing 120...
//                    self.bottomOffset = maxY - 120
//                    // thus we will get our title height 38.....
//                }
//                return Color.clear
//            }
//        )
//    }
//    
//    // opacity...
//    func getOpacity()->CGFloat{
//        if bottomOffset < 28{
//            let progress = bottomOffset / 28
//            return progress
//        }
//        return 1
//    }
//}

struct StickyDateHeader<Header: View, Content: View>: View {
    var headerView: Header
    var contentView: Content

    @State var topOffset: CGFloat = 0

    init(@ViewBuilder headerView: @escaping () -> Header, @ViewBuilder contentView: @escaping () -> Content) {
        self.headerView = headerView()
        self.contentView = contentView()
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                headerView
                    .frame(width: 40, alignment: .top)
                    .padding(.horizontal, 6)
                    .background(Color.theme.backgroundColor)
                    .offset(y: getHeaderOffset())
            }
            .zIndex(1)

            VStack {
                contentView
                    .padding(.trailing, 6)
                    .padding(.vertical, 5)
                Divider()
            }
            .background(Color.theme.backgroundColor)
            .zIndex(0)
        }
        .cornerRadius(12)
        .background(
            GeometryReader { proxy -> Color in
                let minY = proxy.frame(in: .global).minY
                DispatchQueue.main.async {
                    self.topOffset = minY
                }
                return Color.clear
            }
        )
        .colorScheme(.dark)
    }

    func getHeaderOffset() -> CGFloat {
        // The height of the event categories header
        let eventCategoriesHeaderHeight: CGFloat = 200

        // Calculate the offset to keep the date header just below the event categories header
        return max(-topOffset + eventCategoriesHeaderHeight, 0)
    }
}


