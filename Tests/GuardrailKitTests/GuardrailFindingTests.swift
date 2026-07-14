import XCTest
@testable import GuardrailKit

final class GuardrailFindingTests: XCTestCase {
    func testInitAndEquality() {
        let lhs = GuardrailFinding(category: "TEST", severity: .warn, detail: "detail")
        let rhs = GuardrailFinding(category: "TEST", severity: .warn, detail: "detail")
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(lhs.category, "TEST")
        XCTAssertEqual(lhs.severity, .warn)
        XCTAssertEqual(lhs.detail, "detail")
    }
}
