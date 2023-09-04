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
            
            VStack {
                LazyVStack(alignment: .center) {
                    ForEach(Array(viewModel.favoritedEvents)) { event in
                        FavoriteCell(event: event)
                            .environmentObject(viewModel)
                            .navigationDestination(for: Event.self) { event in
                                EventDetailView(event: event)
                            }
                    }
                }
             
                Spacer()
            }
        }
        .navigationBar(title: "Favorites", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
        .onAppear {
            if viewModel.favoritedEvents.isEmpty {
                viewModel.startListeningForFavorites()
            }
        }
    }
}
