import SwiftUI
import UIKit

@MainActor
struct SettingsSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.dismiss) private var dismiss
    @State private var isRequestingNotifications = false

    var body: some View {
        NavigationStack {
            Form {
                let language = languageSettings.selectedLanguage
                Section(Localization.text("settings_section_general", language: language)) {
                    Picker(Localization.text("settings_currency_label", language: language), selection: currencyBinding) {
                        ForEach(DisplayCurrency.allCases) { currency in
                            Text(currency.localizedTitle(language: language)).tag(currency)
                        }
                    }
                    Text(Localization.text("settings_currency_hint", language: language))
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 4)

                    Picker(Localization.text("settings_language_label", language: language), selection: languageBinding) {
                        ForEach(AppLanguage.allCases) { locale in
                            Text(locale.localizedName(in: language)).tag(locale)
                        }
                    }
                    Text(Localization.text("settings_language_hint", language: language))
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 4)
                }

                Section(Localization.text("settings_notifications_section", language: language)) {
                    HStack {
                        Label(notificationStatusLabel, systemImage: "bell.badge.fill")
                            .foregroundStyle(Theme.accent)
                        Spacer()
                        Text(notificationStatusValue)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Text(notificationStatusDescription)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)

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

                Section(Localization.text("settings_privacy_section", language: language)) {
                    NavigationLink(Localization.text("settings_privacy_policy", language: language)) {
                        PrivacyPolicyView()
                            .navigationTitle(Localization.text("privacy_policy_title", language: language))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    Text(Localization.text("settings_privacy_note", language: language))
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                    Text(Localization.text("settings_transparency_note", language: language))
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                    Text(Localization.text("settings_contact_note", language: language))
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle(Localization.text("settings_title", language: languageSettings.selectedLanguage))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localization.text("settings_done", language: languageSettings.selectedLanguage)) { dismiss() }
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

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { languageSettings.selectedLanguage },
            set: { languageSettings.selectedLanguage = $0 }
        )
    }

    private var notificationStatusLabel: String {
        Localization.text("settings_notifications_label", language: languageSettings.selectedLanguage)
    }

    private var notificationStatusValue: String {
        switch appState.notificationStatus {
        case .authorized:
            return Localization.text("notifications_status_active", language: languageSettings.selectedLanguage)
        case .denied:
            return Localization.text("notifications_status_denied", language: languageSettings.selectedLanguage)
        case .provisional:
            return Localization.text("notifications_status_limited", language: languageSettings.selectedLanguage)
        case .notDetermined:
            return Localization.text("notifications_status_unknown", language: languageSettings.selectedLanguage)
        case .unknown:
            return Localization.text("notifications_status_unknown", language: languageSettings.selectedLanguage)
        }
    }

    private var notificationStatusDescription: String {
        switch appState.notificationStatus {
        case .authorized:
            return Localization.text("notifications_description_active", language: languageSettings.selectedLanguage)
        case .denied:
            return Localization.text("notifications_description_denied", language: languageSettings.selectedLanguage)
        case .provisional:
            return Localization.text("notifications_description_limited", language: languageSettings.selectedLanguage)
        case .notDetermined, .unknown:
            return Localization.text("notifications_description_undetermined", language: languageSettings.selectedLanguage)
        }
    }

    private var notificationButtonTitle: String {
        switch appState.notificationStatus {
        case .authorized:
            return Localization.text("notifications_action_open_settings", language: languageSettings.selectedLanguage)
        case .denied:
            return Localization.text("notifications_action_open_settings", language: languageSettings.selectedLanguage)
        case .provisional:
            return Localization.text("notifications_action_adjust", language: languageSettings.selectedLanguage)
        case .notDetermined, .unknown:
            return Localization.text("notifications_action_enable", language: languageSettings.selectedLanguage)
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
