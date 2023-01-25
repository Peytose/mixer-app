//
//  EventInsightView.swift
//  mixer
//
//  Created by Jose Martinez on 1/16/23.
//

import SwiftUI
//
//  HostDashboardView.swift
//  mixer
//
//  Created by Jose Martinez on 1/14/23.
//

import SwiftUI

struct EventInsightView: View {
    
    @Namespace var namespace
    @State private var pieCharts = 0
    @State var selectedChart: PieCharts = .universities
    
    var event: MockEvent
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("After Action Report")
                        .font(.title.bold())
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 2)
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("$0")
                                .font(.largeTitle.weight(.medium))
                            
                            Text("Total Revenue")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text(event.attendance)
                                .font(.largeTitle.weight(.medium))
                            
                            Text("Guests")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("0")
                                .font(.largeTitle.weight(.medium))
                            
                            Text("Reports")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 1)
                    
                    FollowerGraphView(sampleAnalytics: guests, title: "Guests", itemTitle: "Guests", showlinebartoggle: true)
                    
                    CustomStackView {
                        Picker("Pie Chart", selection: $selectedChart.animation() ) {
                            ForEach(PieCharts.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    } contentView: {
                        PieChart(selectedChart: selectedChart, event: event)
                    }

                    CustomStackView {
                        Label {
                            Text("Rings")
                        } icon: {
                            Image(systemName: "person")
                        }
                    } contentView: {
                        LazyVGrid(columns: columns,spacing: 30) {
                            ForEach(1..<5) { x in
                                VStack(spacing: 32) {
                                    
                                    HStack{
                                        
                                        Text("Running")
                                            .font(.system(size: 22))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    
                                    ZStack {
                                        
                                        Circle()
                                            .trim(from: 0, to: 1)
                                            .stroke(Color("graphLavendar").opacity(0.05), lineWidth: 10)
                                            .frame(width: (UIScreen.main.bounds.width - 150) / 2, height: (UIScreen.main.bounds.width - 150) / 2)
                                        
                                        Circle()
                                            .trim(from: 0, to: 7/15)
                                            .stroke(Color("graphLavendar"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .frame(width: (UIScreen.main.bounds.width - 150) / 2, height: (UIScreen.main.bounds.width - 150) / 2)
                                        
                                        Text("45 %")
                                            .font(.system(size: 22))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.blue)
                                            .rotationEffect(.init(degrees: 90))
                                    }
                                    .rotationEffect(.init(degrees: -90))
                                    
                                    Text("6.8 KM")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .background(Color.mixerSecondaryBackground.opacity(0.5))
                                .cornerRadius(15)
                                //                            .shadow(color: Color.white.opacity(0.1), radius: 4, x: 0, y: 0)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color.mixerBackground)
            .preferredColorScheme(.dark)
            .navigationBarTitle(event.title)
        }
    }
}

struct EventInsightView_Previews: PreviewProvider {
    static var previews: some View {
        EventInsightView(event: events[0])
    }
}

enum PieCharts: String, CaseIterable {
    case universities = "Universities"
    case gender = "Gender"
    case relationship = "Relationship"
}

private struct PieChart: View {
    var selectedChart: PieCharts
    var event: MockEvent

    var body: some View {
        switch selectedChart {
        case .universities:
            PieChartView(values: event.schoolValues, names: event.schoolNames, formatter: {value in String(format: "%.f", value)}, title: "Total", showChartRowText: true, chartRowText: "from")
                .frame(height: 580)
            
        case .gender:
            PieChartView(values: event.genderValues, names: ["Female", "Male", "Other"], formatter: { value in String(format: "%.f", value)}, colors: [Color.girlPink, Color.blue, Color.gray], title: "Total", showChartRowText: true, chartRowText: "were")
                .frame(height: 420)
            
        case .relationship:
            PieChartView(values: event.relationshipValues, names: ["Single", "Taken", "Complicated"], formatter: {value in String(format: "%.f", value)}, colors: [Color.green, Color.red, Color.yellow], title: "Total", showChartRowText: true, chartRowText: "were")
                .frame(height: 420)
        }
    }
}
