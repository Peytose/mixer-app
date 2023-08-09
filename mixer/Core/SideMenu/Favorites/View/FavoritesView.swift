//
//  FavoritesView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/8/23.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            List {
                ForEach(Array(viewModel.favorites)) { event in
                    EventCellView(event: event, hasStarted: false, namespace: namespace)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationBar(title: "Favorites", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackArrowButton()
            }
        }
        .onAppear {
            if viewModel.favorites.isEmpty {
                viewModel.startListeningForFavorites()
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
