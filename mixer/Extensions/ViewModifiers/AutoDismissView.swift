//
//  teasdasd.swift
//  mixer
//
//  Created by Peyton Lyons on 8/15/23.
//

import SwiftUI

struct AutoDismissView: ViewModifier {
    let duration: TimeInterval
    @State private var show = true
    
    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        self.show = false
                    }
                }
            }
    }
}
