import Foundation

struct HTTPClient {
    enum HTTPError: LocalizedError {
        case invalidResponse
        case statusCode(Int)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Die Netzwerkanfrage lieferte keine gültige Antwort."
            case .statusCode(let code):
                return "Server meldet Statuscode \(code)."
            }
        }
    }

    func get(_ url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw HTTPError.statusCode(httpResponse.statusCode)
        }
        return data
    }
}
