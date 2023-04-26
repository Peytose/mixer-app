//
//  MailViewModal.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    let subject: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.setToRecipients(["peyton@mixer.llc"])
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody("", isHTML: false)
        mailComposerVC.mailComposeDelegate = context.coordinator
        return mailComposerVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {

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
