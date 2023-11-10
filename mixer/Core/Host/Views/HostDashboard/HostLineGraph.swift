//
//  HostLineGraph.swift
//  mixer
//
//  Created by Jose Martinez on 11/9/23.
//

import SwiftUI
import Charts

struct HostLineGraph: View {
    let viewMonths: [ViewMonth] = [
        .init(date: Date.from(year: 2023, month: 9, day: 10), viewCount: 1000),
        .init(date: Date.from(year: 2023, month: 10, day: 10), viewCount: 1300),
        .init(date: Date.from(year: 2023, month: 10, day: 25), viewCount: 1900),
        .init(date: Date.from(year: 2023, month: 11, day: 10), viewCount: 1200),
        .init(date: Date.from(year: 2023, month: 12, day: 10), viewCount: 1060),
    ]
    
    var width: CGFloat = 150
    
    var body: some View {
        VStack {
            Chart {
                ForEach(viewMonths) { viewMonth in
                    LineMark(x: .value("", viewMonth.date),
                            y: .value("", viewMonth.viewCount))
                    .foregroundStyle(Color.blue)
                }
            }
            .frame(width: width, height: 50)
            .chartYScale(domain: 0...2000)
            .chartPlotStyle { plotContent in
                plotContent
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
//            .chartYAxis {
//                AxisMarks(
//                    values: [0, 100]
//                ) {
//                    AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
//                }
//            }
        }
    }
}

struct HostLineGraph_Previews: PreviewProvider {
    static var previews: some View {
        HostLineGraph()
    }
}


struct  ViewMonth: Identifiable {
    let id = UUID()
    let date: Date
    let viewCount: Int
    
    static let chartData: [ViewMonth] = [
        ViewMonth(date: Date.from(year: 2023, month: 10, day: 12), viewCount:   1800)
    ]
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
        
    }
}
