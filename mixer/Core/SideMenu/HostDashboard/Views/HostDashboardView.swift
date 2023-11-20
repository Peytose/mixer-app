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
    
    init(host: Host) {
        self._viewModel = StateObject(wrappedValue: HostDashboardViewModel(host: host))
    }

    var body: some View {
//        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        dashboardOverview
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Most Recent")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            recentEventInformation
                        }
                                                
                        Divider()
                        
                        seeReportButton
                    }
                    .frame(width: DeviceTypes.ScreenSize.width * 0.95, height: 360, alignment: .top)
                    .padding()
                    .background(Color.theme.secondaryBackgroundColor)
                    .cornerRadius(10)
                    
                    VStack {
                        generalInsights
                    }
                    .padding(.horizontal)
                }
                .navigationTitle(viewModel.host.name)
                .navigationBarTitleDisplayMode(.large)
                .padding(.bottom, 100)
            }
            .background(Color.theme.backgroundColor)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings.toggle() }, label: {
                        Image(systemName: "gearshape")
                    })
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    PresentationBackArrowButton()
                }
            }
            .overlay(alignment: .bottomTrailing) {
                NavigationLink(destination: EventCreationFlowView()) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: .black, radius: 6)
                }
                .padding()
            }
            .sheet(isPresented: $showSettings) {
                HostSettingsView()
            }
//        }
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
            
            Spacer()
            
            Label(title: "earned",
                  value: "$0",
                  isFocus: true)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            NavigationLink(destination: ManageMembersView()) {
                Label(title: "members",
                      value: String(viewModel.memberCount),
                      isButton: true)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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
                        
                        Text("Hosted on \(event.startDate.getTimestampString(format: "MMMM dd, yyyy"))")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if let totalNumGuests = viewModel.totalNumGuests {
                        TextRow(title: "Total Guests:", value: String(totalNumGuests))
                    }
                    
                    if let mostInvitesUser = viewModel.mostInvitesUser {
                        TextRow(title: "Most Invites:", value: mostInvitesUser)
                    }
                    
                    if let mostCheckInsUser = viewModel.mostCheckInsUser {
                        TextRow(title: "Most Check ins:", value: mostCheckInsUser)
                    }
                    
                    if let firstGuestName = viewModel.firstGuestName {
                        TextRow(title: "First Guest:", value: firstGuestName)
                    }
                }
            }
            .foregroundStyle(.white)
        }
    }
    
    var seeReportButton: some View {
        HStack {
            Spacer()
            
            NavigationLink(destination: { EventAfterActionView(host: viewModel.host) }) {
                Text("See full report")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.theme.mixerIndigo)
            }
        }
    }

    
    var generalInsights: some View {
        SectionViewContainer("General Insights") {
            SquareViewContainer(title: "Avg. Attendance", subtitle: "Sep 1 - Now", value: "342", valueTitle: "Guests") {
                HostLineGraph()
            }
        } content2: {
            SquareViewContainer(title: "User Ratings", subtitle: "Sep 1 - Now", value: "4.6", valueTitle: "Stars") {
                HostLineGraph()
            }
        } content3: {
            SquareViewContainer(title: "Guests Served",
                                subtitle: "Sep 1 - Now",
                                value: "4500",
                                valueTitle: "Guests",
                                width: DeviceTypes.ScreenSize.width * 0.92) {
                HostLineGraph(width: 350)
            }
        } navigationDestination: {
            Text("Insights & Analytics")
        }
    }
    
    var eventAnalytics: some View {
        SectionViewContainer("Recent Event Analytics") {
            SquareViewContainer(title: "Gender", subtitle: "Sep 1 - Now", value: "8:4:1", valueTitle: "Ratio") {
                HostLineGraph()
            }
        } content2: {
            SquareViewContainer(title: "Schools", subtitle: "Sep 1 - Now", value: "8", valueTitle: "Schools") {
                HostLineGraph()
            }
        } content3: {
            SquareViewContainer(title: "Attendance Over Time", subtitle: "Sep 1 - Now", value: "427", valueTitle: "Guests", width: DeviceTypes.ScreenSize.width * 0.92) {
                HostLineGraph()
            }
        } navigationDestination: {
            Text("Recent Event Analytics")
        }
    }
}

struct SquareViewContainer<Content: View>: View {
    let content: Content
    //    let destination: Destination
    
    var title: String
    var subtitle: String
    var value: String
    var valueTitle: String
    var width: CGFloat
    var isQuickFact: Bool
    
    init(title: String, subtitle: String = "", value: String, valueTitle: String, width: CGFloat = DeviceTypes.ScreenSize.width * 0.44, isQuickFact: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        //        self.destination = destination()
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.valueTitle = valueTitle
        self.width = width
        self.isQuickFact = isQuickFact
    }
    
    var body: some View {
        VStack(alignment: isQuickFact ? .center : .leading) {
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                       
            Spacer()

            content
                .frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
            
            HStack {
                Text("\(value) \(Text(valueTitle).font(.footnote).foregroundColor(.secondary))")
                Spacer()
            }
        }
        .padding()
        .frame(width: width, height: DeviceTypes.ScreenSize.width * 0.42, alignment: .top)
        .background(Color.theme.secondaryBackgroundColor)
        .cornerRadius(10)
    }
}

struct SectionViewContainer<Content: View, Content2: View>: View {
    var title: String
    let content1: Content
    let content2: Content
    var content3: Content
    
    let navigationDestination: Content2
    
    init(_ title: String, @ViewBuilder content1: () -> Content, @ViewBuilder content2: () -> Content, @ViewBuilder content3: () -> Content, @ViewBuilder navigationDestination: () -> Content2) {
        self.title = title
        self.content1 = content1()
        self.content2 = content2()
        self.content3 = content3()
        self.navigationDestination = navigationDestination()
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text(title)
                    .font(.title2.bold())
                
                Spacer()
                
//                NavigationLink(destination: navigationDestination) {
//                    Text("See all")
//                        .fontWeight(.medium)
//                }
//                .accentColor(Color.theme.mixerIndigo)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                content1
                
                Spacer()
                
                content2
            }
            
            content3
            
        }
        .padding(.top, 25)
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
                    .foregroundStyle(.white)
                
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

struct HostDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        HostDashboardView(host: dev.mockHost)
    }
}
