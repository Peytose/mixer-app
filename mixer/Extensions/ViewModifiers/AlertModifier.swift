//
//  AlertModifier.swift
//  mixer
//
//  Created by Peyton Lyons on 2/29/24.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @Binding var currentAlert: AlertType?
    
    func body(content: Content) -> some View {
        content
            .alert(item: $currentAlert) { alertType in
                switch alertType {
                case .regular(let alertItem):
                    guard let item = alertItem else { return Alert(title: Text("Error")) }
                    return item.alert
                case .confirmation(let confirmationAlertItem):
                    guard let item = confirmationAlertItem else { return Alert(title: Text("Error")) }
                    return item.alert
                }
            }
    }
}

extension View {
    func withAlerts(currentAlert: Binding<AlertType?>) -> some View {
        self.modifier(AlertModifier(currentAlert: currentAlert))
    }
}
