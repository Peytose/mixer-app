//
//  GeometryProxy+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 1/28/23.
//

import SwiftUI

extension GeometryProxy {
    private var offset: CGFloat {
        frame(in: .global).minY
    }
    
    var height: CGFloat {
        size.height + (offset > 0 ? offset : 0)
    }
    
    var verticalOffset: CGFloat {
        offset > 0 ? -offset : 0
    }
}
