//
//  AfterActionReportView.swift
//  mixer
//
//  Created by Jose Martinez on 11/18/23.
//

import SwiftUI
import Kingfisher

struct EventAfterActionView: View {
    @ObservedObject var viewModel: HostDashboardViewModel
    @State private var currentIndex: Int = 0
    
    var charts: [PieChartModel] {
        return viewModel.generateCharts()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                if let event = viewModel.recentEvent {
                    PieChartView(title: event.title,
                                 charts: charts,
                                 currentIndex: $currentIndex)
                }
                ChartKeyPanel(slices: charts[currentIndex].segments, chart: charts[currentIndex])
                
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

fileprivate struct PieChartView: View {
    let title: String
    let charts: [PieChartModel]
    @Binding var currentIndex: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(charts.indices, id: \.self) { index in
                        PieChartViewWrapper(chart: charts[index],
                                            totalCharts: charts.count,
                                            currentIndex: index,
                                            currentTab: $currentIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Spacer()
        }
        .frame(minHeight: 360)
        .padding()
        .background(Color.theme.secondaryBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

fileprivate struct PieChartViewWrapper: View {
    let chart: PieChartModel
    let totalCharts: Int
    let currentIndex: Int
    @Binding var currentTab: Int

    var body: some View {
        VStack {
            Text(chart.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                if currentIndex != 0 {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.secondary)
                        .opacity(currentTab == currentIndex ? 1 : 0.5)
                }
                
                Spacer()
                
                SegmentedPieChartView(slices: chart.segments.map { ($0.value, $0.color) })
                    .frame(maxWidth: 200)
                
                Spacer()
                
                if currentIndex != totalCharts - 1 {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .opacity(currentTab == currentIndex ? 1 : 0.5)
                }
            }
        }
        .padding(.horizontal)
    }
}

fileprivate struct ChartKeyPanel: View {
    let slices: [PieChartSegment]
    let chart: PieChartModel
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
        .padding()
        .background(Color.theme.secondaryBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
