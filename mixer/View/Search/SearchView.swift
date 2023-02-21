//
//  SearchView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.users) { user in
                    NavigationLink {
                        ProfileView(user: user)
                    } label: {
                        Text(user.username)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.mixerBackground.edgesIgnoringSafeArea(.all))
        }
        .searchable(text: $viewModel.text,
                    placement: .automatic,
                    prompt: "Add friends!")
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
    }
}
