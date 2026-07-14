import Foundation
import XCTest
@testable import GuardrailKit

final class GuardrailEventTests: XCTestCase {
    func testInitAndEquality() {
        let timestamp = Date(timeIntervalSince1970: 0)
        let lhs = GuardrailEvent(timestamp: timestamp, phase: .preRequest, verdict: .allow, findingCount: 0)
        let rhs = GuardrailEvent(timestamp: timestamp, phase: .preRequest, verdict: .allow, findingCount: 0)
        XCTAssertEqual(lhs, rhs)
    }
}
