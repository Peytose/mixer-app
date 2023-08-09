////
////  EventFlow.swift
////  mixer
////
////  Created by Peyton Lyons on 3/15/23.
////
//
//import SwiftUI
//
//struct EventFlow: View {
//    @StateObject private var viewModel = EventFlowViewModel()
//    var namespace: Namespace.ID
//    
//    var body: some View {
//        ZStack {
//            Color.theme.backgroundColor.ignoresSafeArea()
//                .onTapGesture { self.hideKeyboard() }
//            
//            viewModel.viewForState()
//                .environmentObject(viewModel)
//        }
//        .overlay(alignment: .bottom) {
//            EventFlowActionButton()
//        }
//        .alert(item: $viewModel.alertItem, content: { $0.alert })
//    }
//}
