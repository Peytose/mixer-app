//
//  HostDashboardView.swift
//  mixer
//
//  Created by Jose Martinez on 11/9/23.
//

import SwiftUI

struct HostDashboardView: View {
    @State private var showSettings = false
    
    var body: some View {
        //        NavigationView {
        ScrollView(showsIndicators: false) {
            VStack {
                tabs
                
                VStack {
                    generalInsights
                    
                    //                        eventAnalytics
                }
                .padding(.horizontal)
            }
            .navigationTitle("MIT Theta Chi")
            .navigationBarTitleDisplayMode(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.theme.backgroundColor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showSettings.toggle() }, label: {
                    Image(systemName: "gearshape")
                })
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSettings) {
            HostSettingsView()
        }
        //        }
    }
}

struct HostDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        HostDashboardView()
            .preferredColorScheme(.dark)
    }
}

extension HostDashboardView {
    var tabs: some View {
        Overview()
    }
    
    var generalInsights: some View {
        SectionViewContainer("General Insights") {
            SquareViewContainer(title: "Avg. Attendance", subtitle: "Sep 1 - Now", value: "342", valueTitle: "guests") {
                HostLineGraph()
            }
        } content2: {
            SquareViewContainer(title: "User Ratings", subtitle: "Sep 1 - Now", value: "4.6", valueTitle: "stars") {
                HostLineGraph()
                
            }
        } content3: {
            SquareViewContainer(title: "Guests Served", subtitle: "Sep 1 - Now", value: "4500", valueTitle: "guests", width: DeviceTypes.ScreenSize.width * 0.92) {
                HostLineGraph(width: 350)
                
            }
        } navigationDestination: {
            Text("Insights & Analytics")
        }
    }
    
    var eventAnalytics: some View {
        SectionViewContainer("Recent Event Analytics") {
            SquareViewContainer(title: "Gender", subtitle: "Sep 1 - Now", value: "8:4:1", valueTitle: "ratio") {
                HostLineGraph()
            }
        } content2: {
            SquareViewContainer(title: "Schools", subtitle: "Sep 1 - Now", value: "8", valueTitle: "schools") {
                HostLineGraph()
            }
        } content3: {
            SquareViewContainer(title: "Attendance Over Time", subtitle: "Sep 1 - Now", value: "427", valueTitle: "guests", width: DeviceTypes.ScreenSize.width * 0.92) {
                HostLineGraph()
            }
        } navigationDestination: {
            Text("Recent Event Analytics")
        }
    }
}


private struct Overview: View {
    var color: Color = .theme.secondaryBackgroundColor
    var body: some View {
        VStack(alignment: .center) {
            Text("Overview")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack(alignment: .bottom) {
                Label(title: "events", value: "9")
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Label(title: "earned", value: "$12,524", isFocus: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Label(title: "members", value: "32")
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image("theta-chi-party-poster")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 180)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Neon Party")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Hosted by MIT Theta Chi")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        
                        TextRow(title: "Total Guests:", value: "436")
                        TextRow(title: "Most Invites:", value: "Andre Hamelburg")
                        TextRow(title: "Most Check ins:", value: "Jose Martinez")
                        TextRow(title: "First Guest:", value: "Alysa Stoner")
                    }
                    .foregroundStyle(.white)
                }
                Spacer()
                
                Divider()
                NavigationLink(destination: { ManageEventsView() }) {
                    HStack {
                        Spacer()
                        Text("See more")
                            .foregroundStyle(.white)
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
            .background(Color.theme.secondaryBackgroundColor)
            .cornerRadius(10)
            
            //            Rectangle()
            //                .overlay {
            //                    Text("Ratings Graph")
            //                        .font(.title2)
            //                        .fontWeight(.semibold)
            //                        .foregroundColor(.black)
            //                }
        }
        .padding()
        .frame(width: DeviceTypes.ScreenSize.width, height: 360, alignment: .top)
        .background(Color.theme.secondaryBackgroundColor)
    }
}
private struct OtherTab: View {
    var color: Color = .theme.secondaryBackgroundColor
    var body: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .font(.title3.bold())
                .padding(.bottom, 5)
            
            
            Text("$12,524")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("earned this month")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: DeviceTypes.ScreenSize.width, height: 360, alignment: .top)
        .background(Color.theme.secondaryBackgroundColor)
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
    
    init(title: String, subtitle: String, value: String, valueTitle: String, width: CGFloat = DeviceTypes.ScreenSize.width * 0.44, @ViewBuilder content: () -> Content) {
        self.content = content()
        //        self.destination = destination()
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.valueTitle = valueTitle
        self.width = width
    }
    
    var body: some View {
        //        NavigationLink(destination: destination) {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            content
            
            Spacer()
            
            Divider()
            
            HStack {
                Text("\(value) \(Text(valueTitle).font(.footnote).foregroundColor(.secondary))")
                Spacer()
                //                    Image(systemName: "chevron.right")
                //                        .font(.subheadline)
            }
        }
        .padding()
        .frame(width: width, height: DeviceTypes.ScreenSize.width * 0.44, alignment: .top)
        .background(Color.theme.secondaryBackgroundColor)
        .cornerRadius(10)
        //        }
        //        .buttonStyle(.plain)
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
                
                NavigationLink(destination: navigationDestination) {
                    Text("See all")
                        .fontWeight(.medium)
                }
                .accentColor(Color.theme.mixerIndigo)
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
    
    var body: some View {
        VStack {
            Text(value)
                .font(isFocus ? .largeTitle : .title2)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
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
