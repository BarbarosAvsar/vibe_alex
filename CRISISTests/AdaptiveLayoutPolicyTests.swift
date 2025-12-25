import XCTest
@testable import CRISIS

final class AdaptiveLayoutPolicyTests: XCTestCase {
    func testPrefersHorizontalWhenHorizontalRegular() {
        let prefers = AdaptiveLayoutPolicy.prefersHorizontal(
            horizontalSizeClass: .regular,
            verticalSizeClass: .compact
        )
        XCTAssertTrue(prefers)
    }

    func testPrefersVerticalWhenHorizontalCompact() {
        let prefers = AdaptiveLayoutPolicy.prefersHorizontal(
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        )
        XCTAssertFalse(prefers)
    }

    func testPrefersHorizontalWhenVerticalRegularAndHorizontalUnknown() {
        let prefers = AdaptiveLayoutPolicy.prefersHorizontal(
            horizontalSizeClass: nil,
            verticalSizeClass: .regular
        )
        XCTAssertTrue(prefers)
    }

    func testPrefersVerticalWhenVerticalCompactAndHorizontalUnknown() {
        let prefers = AdaptiveLayoutPolicy.prefersHorizontal(
            horizontalSizeClass: nil,
            verticalSizeClass: .compact
        )
        XCTAssertFalse(prefers)
    }
}
