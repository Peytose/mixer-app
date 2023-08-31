//
//  EventCreationFlowView.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI

struct EventCreationFlowView: View {
    @EnvironmentObject private var viewModel: EventCreationViewModel
    @State private var eventCreationState = EventCreationState.basicInfo

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
                .onTapGesture { self.hideKeyboard() }
            
            viewModel.viewForState(eventCreationState)
                .transition(.move(edge: .leading))
            
            if viewModel.isLoading { LoadingView() }
        }
        .navigationBar(title: eventCreationState.title, displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .bottom) {
            EventCreationActionButton(state: $eventCreationState)
        }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if eventCreationState != .basicInfo {
                    backArrowButton
                } else {
                    PresentationBackArrowButton()
                }
            }
        }
    }
}

extension EventCreationFlowView {
    var backArrowButton: some View {
        Button { viewModel.previous($eventCreationState) } label: {
            Image(systemName: "arrow.left")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
}
