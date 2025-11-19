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

    init(service: ConsultationServiceProtocol = ConsultationService()) {
        self.service = service
    }

    var isValid: Bool {
        validationError == nil
    }

    var validationError: String? {
        if name.trimmed.count < 2 {
            return "Bitte geben Sie Ihren Namen an."
        }
        if email.trimmed.isEmpty || emailPredicate.evaluate(with: email.trimmed) == false {
            return "Bitte geben Sie eine gültige E-Mail-Adresse an."
        }
        if message.trimmed.count < 10 {
            return "Ihre Nachricht sollte mindestens 10 Zeichen enthalten."
        }
        return nil
    }

    func submit() async -> ConsultationSubmissionResult {
        guard validationError == nil else {
            return .failure(validationError ?? "Ungültige Eingabe")
        }
        isSubmitting = true
        errorMessage = nil
        let payload = ConsultationRequest(
            name: name.trimmed,
            email: email.trimmed,
            phone: phone.trimmed.isEmpty ? nil : phone.trimmed,
            message: message.trimmed,
            locale: Locale.current.identifier
        )

        do {
            try await service.submit(payload)
            isSubmitting = false
            return .success
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            return .failure(error.localizedDescription)
        }
    }

    private let emailPredicate = NSPredicate(
        format: "SELF MATCHES[c] %@",
        "^([A-Z0-9._%+-]+)@([A-Z0-9.-]+)\\.([A-Z]{2,})$"
    )
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
