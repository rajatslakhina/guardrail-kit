import XCTest
@testable import GuardrailKit

final class GuardrailSeverityTests: XCTestCase {
    func testOrdering() {
        XCTAssertLessThan(GuardrailSeverity.info, GuardrailSeverity.warn)
        XCTAssertLessThan(GuardrailSeverity.warn, GuardrailSeverity.block)
        XCTAssertFalse(GuardrailSeverity.block < GuardrailSeverity.info)
    }

    func testAllCases() {
        XCTAssertEqual(GuardrailSeverity.allCases, [.info, .warn, .block])
    }
}
