////
////  FlowActionButton.swift
////  mixer
////
////  Created by Jose Martinez on 4/6/23.
////
//
//import Foundation
//import SwiftUI
//
//struct EventFlowActionButton: View {
//    @EnvironmentObject var viewModel: EventFlowViewModel
//    
//    var buttonText: String {
//        switch viewModel.viewState {
//        case .basicInfo,
//                .locationAndDates,
//                .guestsAndInvitations,
//                .costAndAmenities:
//            return "Continue"
//        case .review:
//            return "Create"
//        }
//    }
//    
//    var body: some View {
//        Button {
//            viewModel.actionForState()
//        } label: {
//            if viewModel.isFormValid {
//                Capsule()
//                    .fill(Color.theme.mixerIndigo.gradient)
//                    .longButtonFrame()
//                    .shadow(color: Color.theme.mixerIndigo.opacity(0.05), radius: 20, x: -8, y: -8)
//                    .shadow(color: Color.theme.mixerIndigo.opacity(0.05), radius: 20, x: 8, y: 8)
//                    .overlay {
//                        Text(buttonText)
//                            .primaryActionButtonFont()
//                    }
//                    .padding(.bottom, 20)
//                
//            } else {
//                Capsule()
//                    .fill(Color.theme.secondaryBackgroundColor)
//                    .longButtonFrame()
//                    .shadow(radius: 10, x: 0, y: 8)
//                    .overlay {
//                        Text(buttonText)
//                            .primaryActionButtonFont()
//                    }
//                    .padding(.bottom, 20)
//            }
//        }
//    }
//}
//
//struct EventFlowActionButton_Previews: PreviewProvider {
//    static var previews: some View {
//        EventFlowActionButton(viewState: .constant(.basicInfo), isActive: .constant(true))
//    }
//}
