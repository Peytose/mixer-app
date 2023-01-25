//
//  HostDashboardView.swift
//  mixer
//
//  Created by Jose Martinez on 1/14/23.
//

import SwiftUI
import TabBar

struct HostDashboardView: View {
    @StateObject private var eventManager = EventManager()
    @State var showEventInsightView = false
    @State var showHostHomePageView = false
    @State var showSettingsView = false
    @State var showCreateEventView = false
    @StateObject private var viewModel = ExplorePageViewModel()
    @Binding var tabBarVisibility: TabBarVisibility
    @State var selectedChart: DashboardCharts = .followers

    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    var eventList: [MockEvent] {
        return events
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    quickStatsSection
                    
                    recentEventsSection
                    
                    Picker("Pie Chart", selection: $selectedChart.animation() ) {
                        ForEach(DashboardCharts.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    Chart(selectedChart: selectedChart)
                        .padding()

                }
                .padding(.horizontal, 5)
            }
            .background(Color.mixerBackground)
            .preferredColorScheme(.dark)
            .navigationBarTitle("MIT Theta Chi")
            .toolbar {
                ToolbarItem() {
                    HStack(spacing: 0) {
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring()) {
                                showCreateEventView.toggle()
                            }
                        }, label: {
                            Image(systemName: "plus")
                                .foregroundColor(Color.mainFont)
                                .font(.system(size: 24).weight(.medium))
                                .shadow(radius: 10)
                        })
                        
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring()) {
                                showHostHomePageView.toggle()
                            }
                        }, label: {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(Color.mainFont)
                                .font(.system(size: 24))
                                .shadow(radius: 10)
                        })
                        
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring()) {
                                showSettingsView.toggle()
                            }
                        }, label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color.mainFont)
                                .font(.system(size: 24))
                                .shadow(radius: 10)
                        })
                    }
                }
            }
            .fullScreenCover(isPresented: $showEventInsightView) {
                EventInsightView(event: eventManager.selectedEvent!)
                    .overlay(alignment: .topTrailing) {
                        XDismissButton()
                            .onTapGesture {
                                showEventInsightView.toggle()
                            }
                            .padding(.trailing)
                    }
            }
            .fullScreenCover(isPresented: $showHostHomePageView) {
                HostOrganizationView(parentViewModel: viewModel, tabBarVisibility: $tabBarVisibility)
            }
            .fullScreenCover(isPresented: $showCreateEventView) {
                CreateEventView()
            }
            .sheet(isPresented: $showSettingsView) {
                HostSettingsView()
            }
        }
    }
    var recentEventsSection: some View {
        CustomStackView {
            Text("Recent Events")
                .font(.title3.weight(.semibold))
        } contentView: {
            ScrollView {
                ForEach(Array(eventList.enumerated().prefix(7)), id: \.offset) { index, event in
                        EventRow(flyer: event.flyer, title: event.title, date: event.date, attendance: event.attendance)
                        .onTapGesture {
                            showEventInsightView.toggle()
                            eventManager.selectedEvent = event
                        }
                }
            }
            .frame(height: 200)
            .padding(.top, -10)
        }
    }
    
    var quickStatsSection: some View {
        HStack(spacing: 30) {
            VStack {
                Text("$0")
                    .font(.largeTitle.weight(.medium))
                
                Text("Total Revenue")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                Text("589")
                    .font(.largeTitle.weight(.medium))
                
                Text("Followers")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                Text("32")
                    .font(.largeTitle.weight(.medium))
                
                Text("Members")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct HostDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        HostDashboardView(tabBarVisibility: .constant(.visible))
    }
}

enum DashboardCharts: String, CaseIterable {
    case followers = "Followers"
    case attendance = "Event Attendance"
}


private struct Chart: View {
    var selectedChart: DashboardCharts
    var body: some View {
        switch selectedChart {
        case .followers:
            FollowerGraphView(sampleAnalytics: followers, title: "Followers", itemTitle: "Followers")

        case .attendance:
            FollowerGraphView(sampleAnalytics: followers, isLineGraph: false, title: "Event Attendance", itemTitle: "Event Attendance")
        }
    }
}
