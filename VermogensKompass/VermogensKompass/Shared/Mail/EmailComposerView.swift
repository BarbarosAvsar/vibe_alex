import SwiftUI
import MessageUI
import UIKit

struct EmailComposerView: UIViewControllerRepresentable {
    let configuration: EmailConfiguration

    func makeUIViewController(context: Context) -> some UIViewController {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = context.coordinator
            controller.setSubject(configuration.subject)
            controller.setToRecipients([configuration.to])
            controller.setMessageBody(configuration.body, isHTML: false)
            return controller
        } else {
            let controller = UIViewController()
            DispatchQueue.main.async {
                let subject = configuration.subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let body = configuration.body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "mailto:\(configuration.to)?subject=\(subject)&body=\(body)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            return controller
        }
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
