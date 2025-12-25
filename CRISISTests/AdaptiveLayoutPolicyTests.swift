import SwiftUI
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
