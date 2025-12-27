import XCTest

#if canImport(CRISIS)
@testable import CRISIS
#elseif canImport(CRISISTahoe)
@testable import CRISISTahoe
#elseif canImport(CRISISVision)
@testable import CRISISVision
#elseif canImport(CRISISWatch)
@testable import CRISISWatch
#endif

@MainActor
final class ConsultationFormViewModelTests: XCTestCase {
    func testValidationFailsForEmptyFields() async {
        let viewModel = ConsultationFormViewModel(service: ConsultationServiceMock())
        viewModel.name = ""
        viewModel.email = "invalid"
        viewModel.message = "Hi"

        let result = await viewModel.submit()

        if case .failure(let message) = result {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected validation failure")
        }
    }

    func testSubmitSendsData() async {
        let service = ConsultationServiceMock()
        let viewModel = ConsultationFormViewModel(service: service)
        viewModel.name = "Anna"
        viewModel.email = "anna@example.com"
        viewModel.phone = "+491234"
        viewModel.message = "Ich hätte gern mehr Infos."

        let result = await viewModel.submit()

        guard case .success = result else {
            return XCTFail("Expected success")
        }
        XCTAssertEqual(service.capturedRequest?.name, "Anna")
        XCTAssertEqual(service.capturedRequest?.phone, "+491234")
    }
}

final class ConsultationServiceMock: ConsultationServiceProtocol {
    private(set) var capturedRequest: ConsultationRequest?
    var shouldFail = false

    func submit(_ request: ConsultationRequest) async throws {
        capturedRequest = request
        if shouldFail {
            throw URLError(.badServerResponse)
        }
    }
}
