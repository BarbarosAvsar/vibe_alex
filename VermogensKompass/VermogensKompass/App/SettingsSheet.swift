import SwiftUI
import UIKit

@MainActor
struct SettingsSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @Environment(\.dismiss) private var dismiss
    @State private var isRequestingNotifications = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Allgemein") {
                    Picker("Anzeigewährung", selection: currencyBinding) {
                        ForEach(DisplayCurrency.allCases) { currency in
                            Text(currency.title).tag(currency)
                        }
                    }
                    Text("Steuert, in welcher Währung Edelmetallpreise im gesamten Interface angezeigt werden.")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 4)
                }

                Section("Benachrichtigungen") {
                    HStack {
                        Label(notificationStatusLabel, systemImage: "bell.badge.fill")
                            .foregroundStyle(Theme.accent)
                        Spacer()
                        Text(notificationStatusValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text(notificationStatusDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button(action: handleNotificationAction) {
                        if isRequestingNotifications {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(notificationButtonTitle)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isRequestingNotifications)
                }

                Section("Beratung & Datenschutz") {
                    NavigationLink("Datenschutzerklärung") {
                        PrivacyPolicyView()
                            .navigationTitle("Datenschutzerklärung")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Datenschutz", systemImage: "lock.shield")
                        Text("Persönliche Daten verlassen Ihr Gerät nur, wenn Sie eine Anfrage senden. Es erfolgt keine lokale Speicherung.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Transparenz", systemImage: "chart.pie.fill")
                        Text("Alle Wirtschaftsdaten stammen aus offenen APIs von GoldPrice.org und der Weltbank.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Kontakt", systemImage: "paperplane")
                        Text("Nutzen Sie den Tab Beratung für individuelle Fragen. Antworten erfolgen DSGVO-konform per E-Mail.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }

    private var currencyBinding: Binding<DisplayCurrency> {
        Binding(
            get: { currencySettings.selectedCurrency },
            set: { currencySettings.selectedCurrency = $0 }
        )
    }

    private var notificationStatusLabel: String {
        "Benachrichtigungen"
    }

    private var notificationStatusValue: String {
        switch appState.notificationStatus {
        case .authorized: return "Aktiv"
        case .denied: return "Deaktiviert"
        case .provisional: return "Begrenzt"
        case .notDetermined: return "Unbekannt"
        case .unknown: return "–"
        }
    }

    private var notificationStatusDescription: String {
        switch appState.notificationStatus {
        case .authorized:
            return "Sie erhalten Warnhinweise bei Benner-Panikphasen oder größeren Krisen."
        case .denied:
            return "Benachrichtigungen sind ausgeschaltet. Aktivieren Sie sie in den iOS-Einstellungen."
        case .provisional:
            return "Temporäre Berechtigung – bestätigen Sie sie, um kritische Hinweise zu behalten."
        case .notDetermined, .unknown:
            return "Noch keine Berechtigung angefragt."
        }
    }

    private var notificationButtonTitle: String {
        switch appState.notificationStatus {
        case .authorized: return "Systemeinstellungen öffnen"
        case .denied: return "In den Einstellungen aktivieren"
        case .provisional: return "Berechtigung bestätigen"
        case .notDetermined, .unknown: return "Benachrichtigungen aktivieren"
        }
    }

    private func handleNotificationAction() {
        switch appState.notificationStatus {
        case .authorized:
            openSystemSettings()
        case .denied:
            openSystemSettings()
        case .provisional, .notDetermined, .unknown:
            Task {
                isRequestingNotifications = true
                defer { isRequestingNotifications = false }
                _ = await appState.requestNotificationAccess()
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
