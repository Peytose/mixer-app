//
//  View+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/13/23.
//

import SwiftUI
import Firebase
import CoreGraphics

extension View {
    @MainActor
    func renderPDF(title: String) -> URL {
        let renderer = ImageRenderer(content: self)
        let url = URL.documentsDirectory.appending(path: "\(title).pdf")
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        return url
    }
    
    
    @MainActor
    func generateSnapshot() -> UIImage {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage ?? UIImage()
    }
    
    
    func autoDismissView(duration: TimeInterval) -> some View {
        self.modifier(AutoDismissView(duration: duration))
    }
    
    
    func navigationBar(title: String, displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        self.navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
    }
    
    
//    // MARK: Guestlist View Extensions
//    func searchBar(text: Binding<String>, viewModel: GuestlistViewModel) -> some View {
//        self.searchable(text: text, prompt: "Search Guests")
//            .onChange(of: text.wrappedValue) { searchText in
//                viewModel.filterGuests(with: searchText)
//            }
//    }
    
    
    // MARK: Notification View Extensions
    func notificationBackground() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 20, height: 60)
            .background(Color.theme.secondaryBackgroundColor)
            .cornerRadius(24)
    }
    
    
    func notificationContentFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 60, height: 60, alignment: .leading)
    }
    
    
    func notificationBackgroundShort() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.5, height: 60)
            .background(Color.theme.secondaryBackgroundColor)
            .cornerRadius(24)
    }
    
    
    func notificationContentFrameShort() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 60, height: 60, alignment: .center)
    }
    
    
    // MARK: Frame Extensions
    func textFieldFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.9)
    }
    
    
    func longButtonFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
    }
}

// MARK: Gesture extension
extension View {
    func swipeGesture(direction: SwipeDirection, action: @escaping () -> Void) -> some View {
        return self.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded { value in
                switch direction {
                case .left where value.translation.width < 0 && abs(value.translation.height) < 30:
                    action()
                case .right where value.translation.width > 0 && abs(value.translation.height) < 30:
                    action()
                case .up where value.translation.height < 0 && abs(value.translation.width) < 100:
                    action()
                case .down where value.translation.height > 0 && abs(value.translation.width) < 100:
                    action()
                default:
                    break
                }
            }
        )
    }
}
