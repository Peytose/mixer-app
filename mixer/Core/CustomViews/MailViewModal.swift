//
//  MailViewModal.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import MessageUI
import SwiftUI

struct MailViewModal: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    let subject: String
    var recipients: [String] // Add a variable for custom recipients

    // Initialize with default recipients if none are provided
    init(isShowing: Binding<Bool>, subject: String, recipients: [String]? = ["peyton.lyons@outlook.com", "jose.martinez102001@gmail.com"]) {
        self._isShowing = isShowing
        self.subject = subject
        self.recipients = recipients!
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailViewModal>) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.setToRecipients(recipients) // Use the variable
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody("", isHTML: false)
        mailComposerVC.mailComposeDelegate = context.coordinator
        return mailComposerVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailViewModal>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool

        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                self.isShowing = false
            }
            controller.dismiss(animated: true)
        }
    }
}
