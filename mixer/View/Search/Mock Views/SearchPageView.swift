//
//  SearchPageView.swift
//  mixer
//
//  Created by Jose Martinez on 12/20/22.
//

import SwiftUI

struct SearchPageView: View {
    @State var text = ""
    @State var selectedUser = users[0]
    
    var body: some View {
        ZStack {
            
            VStack {
                List {
                    content
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.mixerBackground)
            .overlay {
                Image("Blob 1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300, alignment: .top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .opacity(0.8)
                    .offset(x: -40, y: -355)
            }
        }
        .navigationTitle("Search Mixer")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $text, prompt: "Search Users") {
            ForEach(suggestions) { suggestion in
                Text(suggestion.text)
                    .searchCompletion(suggestion.text)
            }
        }
        .preferredColorScheme(.dark)
        .accentColor(.white)
    }
}

struct SearchPageView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPageView()
    }
}

extension SearchPageView {
    var content: some View {
        ForEach(Array(results.enumerated()), id: \.offset) { index, user in
            NavigationLink(destination: UserProfileView(user: user)) {
                HStack(spacing: 15) {
                    Image(user.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 2) {
                            Text(user.name)
                                .font(.callout.weight(.semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "graduationcap.fill")
                                .imageScale(.small)
                                .foregroundColor(.secondary)
                            
                            Text("\(user.school)")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.7))
                            
                            Spacer()
                            
                            Text("Friend")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, -4)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.mixerBackground)
            .swipeActions {
                Button("Add Friend") {
                    print("\(user.name) added as a friend")
                }
                .tint(Color.mixerPurple)
            }
        }
    }
    
//    var results: [Host] {
//
//        if text.isEmpty {
//            return Hosts
//        } else {
//            return Hosts.filter { $0.title.contains(text) }
//        }
//
//    }
    
    var results: [MockUser] {
        
        if text.isEmpty {
            return users
        } else {
            return users.filter { $0.name.localizedCaseInsensitiveContains(text) }
        }
        
    }
    
    var suggestions: [Suggestion2] {
        
        if text.isEmpty {
            return suggestionsData2
        } else {
            return suggestionsData2.filter { $0.text.localizedCaseInsensitiveContains(text) }
        }
        
    }
}

struct Suggestion2: Identifiable {
    let id = UUID()
    var text: String
}

var suggestionsData2 = [
    Suggestion2(text: ""),
]


