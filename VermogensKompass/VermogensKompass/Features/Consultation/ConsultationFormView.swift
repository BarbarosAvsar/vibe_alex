import SwiftUI

struct ConsultationFormView: View {
    @StateObject private var viewModel = ConsultationFormViewModel()
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    @State private var alertContent: AlertContent?
    @State private var didAttemptSubmission = false

    var body: some View {
        Form {
            Section("Kontaktinformationen") {
                TextField("Name*", text: $viewModel.name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)

                TextField("E-Mail*", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .email)

                TextField("Telefon*", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .focused($focusedField, equals: .phone)
            }

            Section("Nachricht") {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 140)
                    .focused($focusedField, equals: .message)
                    .overlay(alignment: .topLeading) {
                        if viewModel.message.isEmpty {
                            Text("Wie können wir Ihnen helfen?*")
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
                        Text("Anfrage senden")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isSubmitting)
            }

            Section {
                Text("Mit dem Absenden stimmen Sie zu, dass wir Ihre Anfrage gemäß Datenschutzerklärung beantworten. Wir speichern keine Daten dauerhaft auf diesem Gerät.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .navigationTitle("Beratung anfragen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") {
                    focusedField = nil
                }
            }
        }
        .alert(item: $alertContent) { content in
            Alert(
                title: Text(content.title),
                message: Text(content.message),
                dismissButton: .default(Text("Okay")) {
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
                    title: "Vielen Dank",
                    message: "Ihre Anfrage wurde gesendet. Wir melden uns zeitnah.",
                    shouldDismiss: true
                )
            case .failure(let message):
                alertContent = AlertContent(
                    title: "Senden fehlgeschlagen",
                    message: message,
                    shouldDismiss: false
                )
            }
        }
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
