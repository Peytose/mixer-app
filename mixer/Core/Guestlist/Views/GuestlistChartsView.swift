//
//  GuestlistChartsView.swift
//  mixer
//
//  Created by Jose Martinez on 4/28/23.
//

import SwiftUI

struct GuestlistChartsView: View {
    var body: some View {
        VStack {
            PieChartView(values: [70, 30, 20], names: ["MIT", "Wellesely", "BU"], formatter: {value in String(format: "%.f", value)}, colors: [Color.red, Color.blue, Color.green])
                .padding(.top, 40)
            
        }
        .background(Color.theme.backgroundColor)

    }
}

struct GuestlistChartsView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistChartsView()
    }
}
