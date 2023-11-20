//
//  AfterActionReportView.swift
//  mixer
//
//  Created by Jose Martinez on 11/18/23.
//

import SwiftUI
import Kingfisher

struct EventAfterActionView: View {
    @StateObject var viewModel: HostDashboardViewModel
    
    var schoolSlicesData = [
        MockPieSliceData(value: 190, color: .red, label: "BU"),
        MockPieSliceData(value: 92, color: .yellow, label: "NEU"),
        MockPieSliceData(value: 30, color: .green, label: "MIT")
    ]
    
    var genderSlicesData = [
        MockPieSliceData(value: 113, color: Color.theme.girlPink, label: "Girls"),
        MockPieSliceData(value: 195, color: Color.theme.mixerBlue, label: "Boys"),
        MockPieSliceData(value: 18, color: .gray, label: "Others")
    ]
    
    init(host: Host) {
        self._viewModel = StateObject(wrappedValue: HostDashboardViewModel(host: host))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                distributionChartsSection
                
                quickFacts
            }
            .navigationTitle("After Action Report")
            .navigationBarTitleDisplayMode(.large)
            .padding(.horizontal)
        }
        .background(Color.theme.backgroundColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
        
    }
}

extension EventAfterActionView {
    var distributionChartsSection: some View {
        VStack(alignment: .leading) {
            Text("Neon Party")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            VStack {
                TabView() {
                    PieChart(slicesData: schoolSlicesData, title: "School Distribution")

                    PieChart(slicesData: genderSlicesData, title: "Gender Distribution")
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Spacer()
        }
        .frame(minHeight: 360)
        .padding()
        .background(Color.theme.secondaryBackgroundColor)
        .cornerRadius(10)
    }
    
    var quickFacts: some View {
        SectionViewContainer("Quick Facts") {
            SquareViewContainer(title: "Total Attendance", value: "450", valueTitle: "Invited", isQuickFact: true) {
                    Text("250")
                    .largeTitle()
            }
        } content2: {
            SquareViewContainer(title: "Total Schools", value: "3", valueTitle: "schools", isQuickFact: true) {
                Text("3")
                    .largeTitle()
            }
        } content3: {
            SquareViewContainer(title: "Most Invites", value: "50", valueTitle: "guests invited", width: DeviceTypes.ScreenSize.width * 0.92, isQuickFact: true) {
                Text("Brian Robinson")
                    .largeTitle()
            }
        } navigationDestination: {
            Text("Recent Event Analytics")
        }
    }
}


struct EventAfterActionView_Previews: PreviewProvider {
    static var previews: some View {
        EventAfterActionView(host: dev.mockHost)
    }
}

fileprivate struct PieChart: View {
    var slicesData: [MockPieSliceData]
    var title: String

    init(slicesData: [MockPieSliceData], title: String) {
        self.slicesData = slicesData
        self.title = title
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Pie(slices: slicesData.map { ($0.value, $0.color) })
                    .frame(maxWidth: 120)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            PieChartLabel(slices: slicesData)
        }
        .padding(.horizontal)
    }
}



fileprivate struct Pie: View {
    var slices: [(Int, Color)]
    var body: some View {
        Canvas { context, size in
            // Add these lines to display as Donut
            //Start Donut
            let donut = Path { p in
                p.addEllipse(in: CGRect(origin: .zero, size: size))
                p.addEllipse(in: CGRect(x: size.width * 0.25, y: size.height * 0.25, width: size.width * 0.5, height: size.height * 0.5))
            }
            context.clip(to: donut, style: .init(eoFill: true))
            //End Donut
            let total = slices.reduce(0) { $0 + $1.0 }
            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            var pieContext = context
            pieContext.rotate(by: .degrees(-90))
            let radius = min(size.width, size.height) * 0.48
            let gapSize = Angle(degrees: 5) // size of the gap between slices in degrees
            
            var startAngle = Angle.zero
            for (value, color) in slices {
                let angle = Angle(degrees: 360 * (Double(value) / Double(total)))
                let endAngle = startAngle + angle
                let path = Path { p in
                    p.move(to: .zero)
                    p.addArc(center: .zero, radius: radius, startAngle: startAngle + Angle(degrees: 5) / 2, endAngle: endAngle, clockwise: false)
                    p.closeSubpath()
                }
                pieContext.fill(path, with: .color(color))
                startAngle = endAngle
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}


fileprivate struct PieChartLabel: View {
    var slices: [MockPieSliceData]
    private var totalValue: Int {
        slices.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(slices, id: \.label) { slice in
                HStack {
                    Circle()
                        .fill(slice.color)
                        .frame(width: 20, height: 20)
                    
                    Text(slice.label)
                    
                    Spacer()
                    
                    Text("\(slice.value) (\(String(format: "%.1f", (Double(slice.value) / Double(totalValue)) * 100))%)")
                }
            }
        }
    }
}

struct MockPieSliceData {
    var value: Int
    var color: Color
    var label: String
}
