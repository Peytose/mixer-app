//
//  MainTabView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import TabBar

struct MainTabView: View {
    //    let user: User
    enum Item: Int, Tabbable {
        case first = 0
        case second
        case third
        case fourth
        case fifth

        
        var icon: String {
            switch self {
                case .first: return "person.3"
                case .second: return "map"
                case .third: return "magnifyingglass"
                case .fourth: return "person"
                case .fifth: return "house"

            }
        }
        
        var title: String {
            switch self {
                case .first: return "Social"
                case .second: return "Map"
                case .third: return "Search"
                case .fourth: return "Profile"
                case .fifth: return "Host"
            }
        }
    }
    
    @State private var selection: Item = .second
    @State private var visibility: TabBarVisibility = .visible
    
    var body: some View {
        TabBar(selection: $selection, visibility: .constant(visibility)) {
            ExplorePageView(tabBarVisibility: $visibility)
                .tabItem(for: Item.first)
            
            MapView()
                .tabItem(for: Item.second)
            
            NavigationView {
                SearchPageView()
            }
            .tabItem(for: Item.third)
            
            UserProfilePrototypeView()
                .tabItem(for: Item.fourth)
            
            HostDashboardView(tabBarVisibility: $visibility)
                .tabItem(for: Item.fifth)
        }
        .tabBar(style: CustomTabBarStyle(height: selection == .second ? 300 : 370))
        .tabItem(style: CustomTabItemStyle())
        .preferredColorScheme(.dark)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
//        MainTabView(user: Mockdata.user)
        MainTabView()
            .environmentObject(Model())
    }
}

struct TabViewItem: View {
    
    enum TabViewItemType: String {
        case social  = "Social"
        case map   = "Map"
        case search = "Search"
        case profile = "Profile"

        var image: Image {
            switch self {
            case .social:  return Image(systemName: "person.3.fill")
            case .map:  return Image(systemName: "map.fill")
            case .search:  return Image(systemName: "magnifyingglass")
            case .profile:  return Image(systemName: "person.fill")
            }
        }

        var text: Text {
            Text(self.rawValue)
        }
    }
    
    var type: TabViewItemType

    var body: some View {
        VStack {
            type.image
                .renderingMode(.template)
                .foregroundColor(.white)
            type.text

        }
    }
}
