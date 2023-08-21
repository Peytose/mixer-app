//
//  EventCreationActionButton.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import Foundation
import SwiftUI

struct EventCreationActionButton: View {
    @EnvironmentObject var viewModel: EventCreationViewModel
    @Binding var state: EventCreationState
    
    var body: some View {
        Button {
            viewModel.actionForState($state)
        } label: {
            Capsule()
                .fill(viewModel.isActionButtonEnabled(forState: state) ? Color.theme.mixerIndigo : Color.theme.secondaryBackgroundColor)
                .longButtonFrame()
                .shadow(color: viewModel.isActionButtonEnabled(forState: state) ? Color.theme.mixerIndigo.opacity(0.05) : .black, radius: 20, x: -8, y: -8)
                .shadow(color: viewModel.isActionButtonEnabled(forState: state) ? Color.theme.mixerIndigo.opacity(0.05) : .black, radius: 20, x: 8, y: 8)
                .overlay {
                    Text(state.buttonText)
                        .primaryActionButtonFont()
                }
                .padding(.bottom, 20)
        }
        .disabled(!viewModel.isActionButtonEnabled(forState: state))
    }
}

struct EventCreationActionButton_Previews: PreviewProvider {
    static var previews: some View {
        EventCreationActionButton(state: .constant(.basicInfo))
    }
}
