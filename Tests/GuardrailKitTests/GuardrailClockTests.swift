import Foundation
import XCTest
@testable import GuardrailKit

final class GuardrailClockTests: XCTestCase {
    func testSystemClockReturnsCurrentTime() {
        let clock = SystemGuardrailClock()
        let before = Date()
        let now = clock.now()
        let after = Date()
        XCTAssertTrue(now >= before && now <= after)
    }
}
