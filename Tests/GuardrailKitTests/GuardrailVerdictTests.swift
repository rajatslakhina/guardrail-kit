import XCTest
@testable import GuardrailKit

final class GuardrailVerdictTests: XCTestCase {
    func testEquality() {
        XCTAssertEqual(GuardrailVerdict.allow, GuardrailVerdict.allow)
        XCTAssertEqual(GuardrailVerdict.redacted, GuardrailVerdict.redacted)
        XCTAssertEqual(GuardrailVerdict.blocked(reason: "x"), GuardrailVerdict.blocked(reason: "x"))
        XCTAssertNotEqual(GuardrailVerdict.blocked(reason: "x"), GuardrailVerdict.blocked(reason: "y"))
        XCTAssertNotEqual(GuardrailVerdict.allow, GuardrailVerdict.redacted)
    }
}
