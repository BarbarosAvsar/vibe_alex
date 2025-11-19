import Foundation

struct ConsultationRequest: Encodable {
    let name: String
    let email: String
    let phone: String?
    let message: String
    let locale: String
}

protocol ConsultationServiceProtocol {
    func submit(_ request: ConsultationRequest) async throws
}

struct ConsultationService: ConsultationServiceProtocol {
    private let client: HTTPClienting
    private let endpoint: URL

    init(endpoint: URL = AppConfig.consultationEndpoint, client: HTTPClienting = HTTPClient()) {
        self.endpoint = endpoint
        self.client = client
    }

    func submit(_ request: ConsultationRequest) async throws {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        _ = try await client.send(urlRequest)
    }
}
