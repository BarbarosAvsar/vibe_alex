import SwiftUI

struct ConsultationFormView: View {
    @StateObject private var viewModel = ConsultationFormViewModel()
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @State private var alertContent: AlertContent?
    @State private var didAttemptSubmission = false

    var body: some View {
        Form {
            let language = languageSettings.selectedLanguage
            Section(Localization.text("consultation_section_expectations", language: language)) {
                Label(Localization.text("consultation_expectation_1", language: language), systemImage: "checkmark.circle.fill")
                Label(Localization.text("consultation_expectation_2", language: language), systemImage: "checkmark.circle.fill")
                Label(Localization.text("consultation_expectation_3", language: language), systemImage: "checkmark.circle.fill")
                Label(Localization.text("consultation_expectation_4", language: language), systemImage: "checkmark.circle.fill")
            }

            Section(Localization.text("consultation_section_contact", language: language)) {
                TextField(Localization.text("consultation_name", language: language), text: $viewModel.name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)

                TextField(Localization.text("consultation_email", language: language), text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .email)

                TextField(Localization.text("consultation_phone", language: language), text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .focused($focusedField, equals: .phone)
            }

            Section(Localization.text("consultation_section_message", language: language)) {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 140)
                    .focused($focusedField, equals: .message)
                    .overlay(alignment: .topLeading) {
                        if viewModel.message.isEmpty {
                            Text(Localization.text("consultation_message_hint", language: language))
                                .foregroundStyle(Theme.textMuted)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
            }

            if let error = currentError {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }

            Section {
                Button(action: submit) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(Localization.text("consultation_submit", language: language))
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isSubmitting)
            }

            Section {
                Text(Localization.text("consultation_privacy_note", language: language))
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }

            Section(Localization.text("consultation_section_more_info", language: language)) {
                infoCard(
                    title: Localization.text("consultation_info_1_title", language: language),
                    text: Localization.text("consultation_info_1_text", language: language)
                )
                infoCard(
                    title: Localization.text("consultation_info_2_title", language: language),
                    text: Localization.text("consultation_info_2_text", language: language)
                )
            }
        }
        .navigationTitle(Localization.text("consultation_title", language: languageSettings.selectedLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Localization.text("settings_done", language: languageSettings.selectedLanguage)) {
                    focusedField = nil
                }
            }
        }
        .alert(item: $alertContent) { content in
            Alert(
                title: Text(content.title),
                message: Text(content.message),
                dismissButton: .default(Text(Localization.text("generic_ok", language: languageSettings.selectedLanguage))) {
                    if content.shouldDismiss {
                        dismiss()
                    }
                }
            )
        }
    }

    private var currentError: String? {
        viewModel.errorMessage ?? (didAttemptSubmission ? viewModel.validationError : nil)
    }

    private func submit() {
        didAttemptSubmission = true
        Task {
            let result = await viewModel.submit()
            switch result {
            case .success:
                alertContent = AlertContent(
                    title: Localization.text("consultation_submit_success_title", language: languageSettings.selectedLanguage),
                    message: Localization.text("consultation_submit_success_message", language: languageSettings.selectedLanguage),
                    shouldDismiss: true
                )
            case .failure(let message):
                alertContent = AlertContent(
                    title: Localization.text("consultation_submit_failure_title", language: languageSettings.selectedLanguage),
                    message: message,
                    shouldDismiss: false
                )
            }
        }
    }

    @ViewBuilder
    private func infoCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "info.circle.fill")
                Text(title)
                    .font(.headline)
        }
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Theme.textMuted)
    }
    .padding()
        .background(
            Theme.accentInfo.opacity(0.24),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

private extension ConsultationFormView {
    enum Field: Hashable {
        case name, email, phone, message
    }

    struct AlertContent: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let shouldDismiss: Bool
    }
}
