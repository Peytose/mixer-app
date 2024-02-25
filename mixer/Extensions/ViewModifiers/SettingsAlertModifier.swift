//
//  SettingsAlertModifier.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/24.
//

import SwiftUI

struct SettingsAlertModifier<ViewModel: SettingsConfigurable>: ViewModifier {
    @ObservedObject var viewModel: ViewModel

    func body(content: Content) -> some View {
        content
            .alert(viewModel.chosenRow?.alertTitle ?? "", isPresented: $viewModel.showAlert) {
                TextField(viewModel.chosenRow?.alertPlaceholder ?? "",
                          text: viewModel.content(for: viewModel.chosenRow?.title ?? ""))
                        
                if #available(iOS 16.0, *) {
                    Button("Save") {
                        viewModel.save(for: viewModel.saveType(for: viewModel.chosenRow?.title ?? ""))
                    }
                    Button("Cancel", role: .cancel, action: {})
                }
            } message: { Text(viewModel.chosenRow?.alertMessage ?? "") }
    }
}
