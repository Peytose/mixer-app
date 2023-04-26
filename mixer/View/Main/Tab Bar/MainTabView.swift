//
//  MainTabView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import TabBar

struct MainTabView: View {
    let user: CachedUser
    
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
                case .first: return "Explore"
                case .second: return "Map"
                case .third: return "Search"
                case .fourth: return "Profile"
                case .fifth: return "Host"
            }
        }
    }
    
    @State private var selection: Item = .second
    @State private var visibility: TabBarVisibility = .visible
    @Namespace var namespace
    
    var body: some View {
        TabBar(selection: $selection, visibility: .constant(visibility)) {
            ExploreView()
                .tabItem(for: Item.first)

            MapTemp(namespace: namespace)
                .tabItem(for: Item.second)
            
            SearchView()
                .tabItem(for: Item.third)

            NavigationView {
                ProfileView(viewModel: ProfileViewModel(user: user))
            }
            .tabItem(for: Item.fourth)
        }
        .tabBar(style: CustomTabBarStyle(height: selection == .second ? 300 : 370))
        .tabItem(style: CustomTabItemStyle())
        .preferredColorScheme(.dark)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(user: CachedUser(from: Mockdata.user))
    }
}

struct TabViewItem: View {
    
    enum TabViewItemType: String {
        case social  = "Explore"
        case map   = "Map"
        case search = "Search"
        case profile = "Profile"

        var image: Image {
            switch self {
            case .social:  return Image(systemName: "music.note.house.fill")
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
