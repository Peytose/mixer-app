//
//  ManageEventsView.swift
//  mixer
//
//  Created by Peyton Lyons on 9/14/23.
//

import SwiftUI

struct ManageEventsView: View {
    @StateObject var viewModel = ManageEventsViewModel()

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                StickyHeaderView(items: EventState.allCases,
                                 selectedItem: $viewModel.currentState)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: .zero), count: 2), spacing: 10) {
                        ForEach(viewModel.eventsForSelectedState) { event in
                            NavigationLink {
                                GuestlistView(event: event)
                            } label: {
                                ManageEventCell(viewModel: viewModel, event: event)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
        .navigationBar(title: "Manage Events", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
    }
}

//struct ManageEventsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ManageEventsView()
//    }
//}
