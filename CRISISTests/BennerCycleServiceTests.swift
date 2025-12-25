import XCTest
@testable import CRISIS

final class BennerCycleServiceTests: XCTestCase {
    private let service = BennerCycleService(range: 1780...2150)

    func testGeneratesEntriesForConfiguredRange() {
        let entries = service.makeEntries()
        XCTAssertGreaterThan(entries.count, 200)
        XCTAssertEqual(entries.first?.year, 1780)
        XCTAssertEqual(entries.last?.year, 2150)
    }

    func testIdentifiesKnownPanicYear() {
        let entries = service.makeEntries()
        let panic = entries.first(where: { $0.year == 2008 })
        XCTAssertEqual(panic?.phase, .panic)
    }

    func testGoodTimesFollowPanic() {
        let entries = service.makeEntries()
        let sample = entries.first(where: { $0.year == 2014 })
        XCTAssertEqual(sample?.phase, .goodTimes)
        XCTAssertEqual(sample?.phaseLength, 7)
    }

    func testHardTimesCoverLongerWindow() {
        let entries = service.makeEntries()
        let sample = entries.first(where: { $0.year == 2023 })
        XCTAssertEqual(sample?.phase, .hardTimes)
        XCTAssertGreaterThanOrEqual(sample?.phaseLength ?? 0, 8)
    }
}

