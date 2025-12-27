import SwiftUI

@MainActor
struct NotificationOnboardingView: View {
    let status: NotificationAuthorizationState
    let enableAction: () async -> Bool
    let skipAction: () -> Void
    let completion: (Bool) -> Void

    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.dismiss) private var dismiss
    @State private var wantsAlerts = true
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    let language = languageSettings.selectedLanguage
                    VStack(spacing: 12) {
                        Image(systemName: "bell.badge.fill")
                            .font(.largeTitle)
                            .symbolRenderingMode(.multicolor)
                        Text(Localization.text("notification_onboarding_headline", language: language))
                            .font(.title2.bold())
                        Text(Localization.text("notification_onboarding_body", language: language))
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .foregroundStyle(Theme.textSecondary)
                        if let statusHint = statusHintText {
                            Text(statusHint)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(.top, 8)

                    Toggle(isOn: $wantsAlerts) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Localization.text("notification_onboarding_toggle_title", language: language))
                                .font(.headline)
                            Text(Localization.text("notification_onboarding_toggle_hint", language: language))
                                .font(.footnote)
                                .foregroundStyle(Theme.textMuted)
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
                        Label(Localization.text("notification_onboarding_device_hint", language: language), systemImage: "lock.shield")
                            .font(.footnote)
                        Label(Localization.text("notification_onboarding_privacy_hint", language: language), systemImage: "checkmark.seal")
                            .font(.footnote)
                    }
                    .foregroundStyle(Theme.textMuted)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        guard wantsAlerts else {
                            errorMessage = Localization.text("notification_onboarding_error_toggle", language: language)
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
                                errorMessage = Localization.text("notification_onboarding_error_settings", language: language)
                                completion(false)
                            }
                        }
                    } label: {
                        if isProcessing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(Localization.text("notification_onboarding_enable", language: language))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)

                    Button(Localization.text("notification_onboarding_later", language: language), role: .cancel) {
                        skipAction()
                        dismiss()
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .navigationTitle(Localization.text("notification_onboarding_title", language: languageSettings.selectedLanguage))
            .toolbar {
                ToolbarItem(placement: AdaptiveToolbarPlacement.trailing) {
                    Button(Localization.text("settings_done", language: languageSettings.selectedLanguage)) {
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
        let language = languageSettings.selectedLanguage
        switch status {
        case .denied:
            return Localization.text("notifications_description_denied", language: language)
        case .provisional:
            return Localization.text("notification_banner_message_limited", language: language)
        default:
            return nil
        }
    }
}

@MainActor
struct NotificationPermissionBanner: View {
    let status: NotificationAuthorizationState
    let action: () -> Void
    @Environment(LanguageSettings.self) private var languageSettings

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
                    .foregroundStyle(Theme.textMuted)
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
        let language = languageSettings.selectedLanguage
        switch status {
        case .denied:
            return Localization.text("notification_banner_denied", language: language)
        case .provisional:
            return Localization.text("notification_banner_limited", language: language)
        case .notDetermined:
            return Localization.text("notification_banner_missing", language: language)
        default:
            return Localization.text("settings_notifications_label", language: language)
        }
    }

    private var statusMessage: String {
        let language = languageSettings.selectedLanguage
        switch status {
        case .denied:
            return Localization.text("notification_banner_message_denied", language: language)
        case .provisional:
            return Localization.text("notification_banner_message_limited", language: language)
        case .notDetermined:
            return Localization.text("notification_banner_message_missing", language: language)
        default:
            return ""
        }
    }

    private var buttonTitle: String {
        let language = languageSettings.selectedLanguage
        switch status {
        case .denied:
            return Localization.text("notification_banner_action_settings", language: language)
        case .provisional:
            return Localization.text("notification_banner_action_adjust", language: language)
        default:
            return Localization.text("notification_onboarding_enable", language: language)
        }
    }
}
