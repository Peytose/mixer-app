//
//  HostDashboardView.swift
//  mixer
//
//  Created by Jose Martinez on 11/9/23.
//

import SwiftUI
import Kingfisher

struct HostDashboardView: View {
    @StateObject var viewModel: HostDashboardViewModel
    @State private var showSettings = false
    
    init() {
        _viewModel = StateObject(wrappedValue: HostDashboardViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HostMenuView(viewModel: viewModel,
                             showSettings: $showSettings)
                .padding(.bottom, 10)
                .padding(.top, 20)
                
                VStack {
                    dashboardOverview
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.recentEvent != nil ? "Most Recent" : "Post an Event")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        recentEventInformation
                        
                        Spacer()
                    }
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])

                    
                    Divider()
                    
                    if let _ = viewModel.recentEvent {
                        seeReportButton
                    }
                }
                .frame(minHeight: 360)
                .padding()
                .background(Color.theme.secondaryBackgroundColor)
                .cornerRadius(10)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                            .scaleEffect(2)
                    } else {
                        SectionViewContainer(title: "Quick Stats",
                                             quickStatistics: $viewModel.quickStatistics,
                                             isLoading: $viewModel.isLoading)
                    }
                }
            }
            .padding(.bottom, 140)
        }
        .padding(.horizontal, 17)
        .background {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            Image(.blob1)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 300, alignment: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .opacity(0.8)
                .rotationEffect(Angle(degrees: 180))
                .offset(x: -20, y: -420)

        }
        .overlay(alignment: .bottomTrailing) {
            if let hostId = viewModel.currentHost?.id,
               let privileges = UserService.shared.user?.hostIdToMemberTypeMap?[hostId]?.privileges,
               privileges.contains(.createEvents) {
                NavigationLink(destination: EventCreationFlowView()) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: .black, radius: 6)
                }
                .padding(.bottom, 120)
                .padding(.trailing)
            }
        }
        .sheet(isPresented: $showSettings) {
            if let host = UserService.shared.user?.currentHost {
                HostSettingsView(host: host)
            }
        }
    }
}

struct HostMenuView: View {
    @ObservedObject var viewModel: HostDashboardViewModel
    @Binding var showSettings: Bool
    
    @State private var isActive: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            if let hosts = viewModel.memberHosts {
                Menu {
                    ForEach(hosts) { host in
                        Button {
                            viewModel.selectHost(host)
                        } label: {
                            HStack {
                                Text(host.name)

                                if host.username == UserService.shared.user?.currentHost?.username {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.currentHost?.name ?? "n/a")
                            .font(.title)
                            .fontWeight(.semibold)

                        if hosts.count > 1 {
                            Image(systemName: isActive ? "chevron.down" : "chevron.right")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(Color.white)
                }
            }
            
            Spacer()
            
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
            }
        }
    }
}

extension HostDashboardView {
    var dashboardOverview: some View {
        HStack(alignment: .center) {
            NavigationLink(destination: ManageEventsView()) {
                Label(title: "events",
                      value: String(viewModel.eventCount),
                      isButton: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .redacted(reason: viewModel.isLoading ? .placeholder : [])

            Spacer()
            
            Label(title: "earned",
                  value: "$0",
                  isFocus: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .redacted(reason: viewModel.isLoading ? .placeholder : [])

            Spacer()
            
            NavigationLink(destination: ManageMembersView()) {
                Label(title: "members",
                      value: String(viewModel.memberCount),
                      isButton: true)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
        }
    }
    
    var recentEventInformation: some View {
        HStack(alignment: .top) {
            if let event = viewModel.recentEvent {
                KFImage(URL(string: event.eventImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 180)
                    .cornerRadius(10, corners: .topRight)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    if let event = viewModel.recentEvent {
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        
                        Text("Hosted on \(event.startDate.getTimestampString(format: "MMMM dd, yyyy"))")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.recentStatistics.keys.sorted(), id: \.self) { key in
                        if let value = viewModel.recentStatistics[key] {
                            TextRow(title: key, value: value)
                                .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        }
                    }
                }
            }
            .foregroundColor(.white)
        }
    }
    
    var seeReportButton: some View {
        HStack {
            Spacer()
            
            NavigationLink {
                EventDetailedChartsView(viewModel: viewModel)
            } label: {
                Text("See charts")
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.mixerIndigo)
            }
        }
    }
}

struct SquareViewContainer<Content: View>: View {
    let content: Content
    var title: String
    var subtitle: String
    var secondaryValue: String
    var secondaryLabel: String
    var width: CGFloat
    @Binding var isLoading: Bool
    
    init(title: String, subtitle: String = "", secondaryValue: String, secondaryLabel: String, width: CGFloat = DeviceTypes.ScreenSize.width * 0.44, isLoading: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
        self.subtitle = subtitle
        self.secondaryValue = secondaryValue
        self.secondaryLabel = secondaryLabel
        self.width = width
        self._isLoading = isLoading
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                       
            Spacer()

            content
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
            Divider()
            
            HStack {
                Text("\(Text(secondaryValue).font(.subheadline).foregroundColor(.white)) \(Text(secondaryLabel).font(.footnote).foregroundColor(.secondary))")
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Spacer()
            }
        }
        .padding()
        .frame(width: width, height: DeviceTypes.ScreenSize.width * 0.42, alignment: .top)
        .background(Color.theme.secondaryBackgroundColor)
        .cornerRadius(10)
    }
}

struct SectionViewContainer: View {
    var title: String
    @Binding var quickStatistics: [String: (String, String, String)]
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
                .padding(.bottom)

            let sortedStats = quickStatistics.sorted(by: { $0.key.count < $1.key.count })
            let statsCount = sortedStats.count
            
            if statsCount == 1 {
                if let stat = sortedStats.first {
                    LargeStatView(title: stat.key,
                                  value: stat.value.0,
                                  secondaryValue: stat.value.1,
                                  secondaryLabel: stat.value.2)
                }
            } else {
                VStack(alignment: .center) {
                    HStack {
                        ForEach(sortedStats.prefix(2), id: \.key) { key, value in
                            StandardStatView(title: key,
                                             value: value.0,
                                             secondaryValue: value.1,
                                             secondaryLabel: value.2)
                            if sortedStats.prefix(2).first?.key == key {
                                Spacer()
                            }
                        }
                    }
                    
                    if statsCount == 3 {
                        if let largeStat = sortedStats.last {
                            LargeStatView(title: largeStat.key,
                                          value: largeStat.value.0,
                                          secondaryValue: largeStat.value.1,
                                          secondaryLabel: largeStat.value.2)
                            .padding(.top)
                        }
                    }
                }
            }
        }
        .padding(.top, 25)
    }
    
    
    // Define a view for a larger stat container
    @ViewBuilder
    private func LargeStatView(title: String, value: String, secondaryValue: String, secondaryLabel: String) -> some View {
        // Implement the view with a larger width
        SquareViewContainer(title: title,
                            secondaryValue: secondaryValue,
                            secondaryLabel: secondaryLabel,
                            width: DeviceTypes.ScreenSize.width * 0.92,
                            isLoading: $isLoading) {
            Text(value)
                .largeTitle()
        }
    }
    
    // Define a standard view for stats
    @ViewBuilder
    private func StandardStatView(title: String, value: String, secondaryValue: String, secondaryLabel: String) -> some View {
        // Implement the view with standard sizing
        SquareViewContainer(title: title,
                            secondaryValue: secondaryValue,
                            secondaryLabel: secondaryLabel,
                            isLoading: $isLoading) {
            Text(value)
                .largeTitle()
        }
    }
}

private struct Label: View {
    var title: String
    var value: String
    var isFocus: Bool = false
    var isButton: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                Text(value)
                    .font(isFocus ? .largeTitle : .title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80)
        .padding(4)
        .background(isButton ? Color.theme.tertiaryBackground : nil)
        .cornerRadius(12)
    }
}

private struct TextRow: View {
    var title: String
    var value: String
    var body: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
            
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}
