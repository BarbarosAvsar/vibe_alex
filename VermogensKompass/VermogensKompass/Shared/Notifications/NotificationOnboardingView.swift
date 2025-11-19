import SwiftUI

struct NotificationOnboardingView: View {
    let status: NotificationAuthorizationState
    let enableAction: () async -> Bool
    let skipAction: () -> Void
    let completion: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var wantsAlerts = true
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.largeTitle)
                        .symbolRenderingMode(.multicolor)
                    Text("Krisen-Alerts")
                        .font(.title2.bold())
                    Text("Erhalten Sie einmalige Push-Mitteilungen bei Hochrisiko-Ereignissen. Wir senden nur Meldungen, wenn die Lage ernst ist.")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    if let statusHint = statusHintText {
                        Text(statusHint)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
                    .padding(.top, 8)

                    Toggle(isOn: $wantsAlerts) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Echtzeit-Benachrichtigungen")
                                .font(.headline)
                            Text("Nur Krisen ab Schweregrad 5 und keine Werbung.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(.switch)
                    .padding()
                    .background(
                        Theme.surface,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Theme.border.opacity(0.5), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sie können Ihre Entscheidung jederzeit in den iOS-Einstellungen ändern.", systemImage: "lock.shield")
                            .font(.footnote)
                        Label("Keine Daten verlassen Ihr Gerät. Grundlage: App Store Guideline 5.1.1.", systemImage: "checkmark.seal")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        guard wantsAlerts else {
                            errorMessage = "Aktivieren Sie die Umschaltung, um Benachrichtigungen zu erlauben."
                            return
                        }
                        Task {
                            isProcessing = true
                            let granted = await enableAction()
                            isProcessing = false
                            if granted {
                                completion(true)
                                dismiss()
                            } else {
                                errorMessage = "Bitte erlauben Sie Mitteilungen in den iOS-Einstellungen."
                                completion(false)
                            }
                        }
                    } label: {
                        Text(isProcessing ? "Aktiviere…" : "Krisen-Alerts aktivieren")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)

                    Button("Vielleicht später", role: .cancel) {
                        skipAction()
                        dismiss()
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .navigationTitle("Mitteilungen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        skipAction()
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension NotificationOnboardingView {
    var statusHintText: String? {
        switch status {
        case .denied:
            return "Benachrichtigungen sind derzeit deaktiviert. Aktivieren Sie sie unten oder in den iOS-Einstellungen."
        case .provisional:
            return "Aktuell werden Meldungen nur still zugestellt. Aktivieren Sie Töne/Banner für Krisen-Alerts."
        default:
            return nil
        }
    }
}

struct NotificationPermissionBanner: View {
    let status: NotificationAuthorizationState
    let action: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(Theme.accentStrong)
                .imageScale(.large)
                .padding(8)
                .background(
                    Theme.accentStrong.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(statusTitle)
                    .font(.headline)
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.caption.bold())
                }
                .buttonStyle(.borderless)
            }
            Spacer()
        }
        .padding(14)
        .background(
            Theme.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.border.opacity(0.6), lineWidth: 1)
        )
    }

    private var statusTitle: String {
        switch status {
        case .denied:
            return "Krisen-Alerts deaktiviert"
        case .provisional:
            return "Krisen-Alerts in Ruhigstellung"
        case .notDetermined:
            return "Krisen-Alerts noch nicht aktiviert"
        default:
            return "Benachrichtigungen"
        }
    }

    private var statusMessage: String {
        switch status {
        case .denied:
            return "Aktivieren Sie Benachrichtigungen, um akute Krisen sofort zu sehen."
        case .provisional:
            return "App Mitteilungen werden momentan nur still zugestellt. Aktivieren Sie Banner/Töne."
        case .notDetermined:
            return "Tippen Sie hier, um Push-Mitteilungen für Hochrisiko-Lagen einzuschalten."
        default:
            return ""
        }
    }

    private var buttonTitle: String {
        switch status {
        case .denied:
            return "Einstellungen öffnen"
        case .provisional:
            return "Einstellungen anpassen"
        default:
            return "Krisen-Alerts aktivieren"
        }
    }
}
