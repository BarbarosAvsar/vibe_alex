import SwiftUI
import MessageUI
import UIKit

struct EmailComposerView: UIViewControllerRepresentable {
    let configuration: EmailConfiguration

    func makeUIViewController(context: Context) -> UIViewController {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = context.coordinator
            controller.setSubject(configuration.subject)
            controller.setToRecipients([configuration.to])
            controller.setMessageBody(configuration.body, isHTML: false)
            return controller
        } else {
            return UIHostingController(rootView: MailFallbackView(configuration: configuration))
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

private struct MailFallbackView: View {
    let configuration: EmailConfiguration
    @State private var didCopyAddress = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Apple Mail ist nicht eingerichtet")
                        .font(.title3.bold())
                    Text("Sie können uns trotzdem kontaktieren: kopieren Sie die E-Mail-Adresse oder öffnen Sie unsere Kontaktseite.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Button {
                    UIPasteboard.general.string = configuration.to
                    withAnimation {
                        didCopyAddress = true
                    }
                } label: {
                    Label("Adresse kopieren", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if didCopyAddress {
                    Text("Adresse kopiert. Fügen Sie sie in Ihre bevorzugte Mail-App ein.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Link(destination: AppConfig.contactWebsite) {
                    Label("Kontaktseite öffnen", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding()
            .navigationTitle("Kontakt")
        }
    }
}
