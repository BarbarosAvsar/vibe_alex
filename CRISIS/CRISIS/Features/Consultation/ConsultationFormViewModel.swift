import Foundation

@MainActor
final class ConsultationFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var message: String = ""
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?

    private let service: ConsultationServiceProtocol
    private let languageKey = "preferredLanguage"

    init(service: ConsultationServiceProtocol = ConsultationService()) {
        self.service = service
    }

    var isValid: Bool {
        validationError == nil
    }

    var validationError: String? {
        if name.trimmed.count < 2 {
            return Localization.text("consultation_error_name", language: selectedLanguage)
        }
        if email.trimmed.isEmpty || emailPredicate.evaluate(with: email.trimmed) == false {
            return Localization.text("consultation_error_email", language: selectedLanguage)
        }
        if phone.trimmed.count < 5 {
            return Localization.text("consultation_error_phone", language: selectedLanguage)
        }
        if message.trimmed.count < 10 {
            return Localization.text("consultation_error_message", language: selectedLanguage)
        }
        return nil
    }

    func submit() async -> ConsultationSubmissionResult {
        guard validationError == nil else {
            return .failure(validationError ?? Localization.text("consultation_error_invalid", language: selectedLanguage))
        }
        isSubmitting = true
        errorMessage = nil
        let payload = ConsultationRequest(
            name: name.trimmed,
            email: email.trimmed,
            phone: phone.trimmed,
            message: message.trimmed,
            locale: selectedLanguage.locale.identifier
        )

        do {
            try await service.submit(payload)
            isSubmitting = false
            return .success
        } catch {
            isSubmitting = false
            let fallback = Localization.text("consultation_submit_failure_message", language: selectedLanguage)
            let message = error.localizedDescription.isEmpty ? fallback : error.localizedDescription
            errorMessage = message
            return .failure(message)
        }
    }

    private let emailPredicate = NSPredicate(
        format: "SELF MATCHES[c] %@",
        "^([A-Z0-9._%+-]+)@([A-Z0-9.-]+)\\.([A-Z]{2,})$"
    )

    private var selectedLanguage: AppLanguage {
        if let stored = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: stored) {
            return language
        }
        return .german
    }
}

enum ConsultationSubmissionResult {
    case success
    case failure(String)
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
