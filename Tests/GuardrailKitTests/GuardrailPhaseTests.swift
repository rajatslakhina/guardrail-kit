import XCTest
@testable import GuardrailKit

final class GuardrailPhaseTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(GuardrailPhase.preRequest.rawValue, "preRequest")
        XCTAssertEqual(GuardrailPhase.postResponse.rawValue, "postResponse")
    }

    func testAllCases() {
        XCTAssertEqual(GuardrailPhase.allCases, [.preRequest, .postResponse])
    }
}
