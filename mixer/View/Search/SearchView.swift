//
//  SearchView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import Kingfisher
import DebouncedOnChange

struct SearchView: View {
    @ObservedObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.users) { user in
                        NavigationLink {
                            ProfileView(user: user)
                        } label: {
                            UserSearchCell(username: user.username,
                                           name: user.name,
                                           imageUrl: user.profileImageUrl)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
                if viewModel.isLoading { LoadingView() }
            }
            .searchable(text: $viewModel.text,
                        placement: .automatic,
                        prompt: "Add friends!")
            .onChange(of: viewModel.text, debounceTime: 0.8) { search in
                viewModel.executeSearch(for: search)
            }
        }
        .background(Color.mixerBackground.edgesIgnoringSafeArea(.all))
    }
}

fileprivate struct UserSearchCell: View {
    let username: String
    let name: String
    let imageUrl: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 34, height: 34)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("@\(username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
    }
}
