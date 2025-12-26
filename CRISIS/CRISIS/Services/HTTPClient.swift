import CryptoKit
import Foundation

protocol HTTPClienting: Sendable {
    func get(_ url: URL) async throws -> Data
    func send(_ request: URLRequest) async throws -> Data
}

struct HTTPClient: HTTPClienting {
    enum HTTPError: LocalizedError {
        case invalidResponse
        case statusCode(Int)
        case insecureRequest

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Die Netzwerkanfrage lieferte keine gültige Antwort."
            case .statusCode(let code):
                return "Server meldet Statuscode \(code)."
            case .insecureRequest:
                return "Unsichere Netzwerkverbindung blockiert."
            }
        }
    }

    private let session: URLSession
    private let pinningDelegate: CertificatePinningDelegate?

    init(
        session: URLSession? = nil,
        pins: [String: [String]] = AppConfig.certificatePins
    ) {
        if let session {
            self.session = session
            self.pinningDelegate = nil
            return
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 40

        if pins.isEmpty {
            self.session = URLSession(configuration: configuration)
            self.pinningDelegate = nil
        } else {
            let delegate = CertificatePinningDelegate(pins: pins)
            self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
            self.pinningDelegate = delegate
        }
    }

    func get(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await send(request)
    }

    func send(_ request: URLRequest) async throws -> Data {
        guard request.url?.scheme?.lowercased() == "https" else {
            throw HTTPError.insecureRequest
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw HTTPError.statusCode(httpResponse.statusCode)
        }
        return data
    }
}

private final class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinsByHost: [String: Set<String>]

    init(pins: [String: [String]]) {
        self.pinsByHost = pins.mapValues { Set($0.map { $0.replacingOccurrences(of: "sha256/", with: "") }) }
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let host = challenge.protectionSpace.host
        guard let pins = pinsByHost[host], pins.isEmpty == false else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard SecTrustEvaluateWithError(serverTrust, nil),
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
              let publicKey = SecCertificateCopyKey(certificate),
              let keyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let hash = SHA256.hash(data: keyData)
        let base64Hash = Data(hash).base64EncodedString()
        if pins.contains(base64Hash) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
