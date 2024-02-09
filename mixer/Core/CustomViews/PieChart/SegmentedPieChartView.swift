//
//  SegmentedPieChartView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/20/23.
//

import SwiftUI

struct SegmentedPieChartView: View {
    var slices: [(value: Int, color: Color)]
    
    var body: some View {
        Canvas { context, size in
            let total = slices.reduce(0) { $0 + $1.value }
            context.translateBy(x: size.width / 2, y: size.height / 2)
            var startAngle = Angle.degrees(0)
            let radius = min(size.width, size.height) / 2
            
            for slice in slices {
                let valuePercentage = Double(slice.value) / Double(total)
                let endAngle = startAngle + Angle.degrees(valuePercentage * 360)
                
                // Adjust gap size here
                let gapSize = Angle.degrees(1) // Smaller gap size
                let adjustedEndAngle = endAngle - gapSize
                
                // Draw segment
                let path = Path { p in
                    p.move(to: CGPoint.zero)
                    p.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: adjustedEndAngle, clockwise: false)
                    p.closeSubpath()
                }
                
                context.fill(path, with: .color(slice.color))
                
                // Update start angle for the next segment, including the gap
                startAngle = endAngle
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
