import XCTest
@testable import GuardrailKit

final class GuardrailOutcomeTests: XCTestCase {
    func testTextToForwardWhenAllowed() {
        let outcome = GuardrailOutcome(
            phase: .preRequest,
            originalText: "hi",
            sanitizedText: "hi",
            findings: [],
            verdict: .allow
        )
        XCTAssertEqual(outcome.textToForward, "hi")
    }

    func testTextToForwardWhenRedacted() {
        let outcome = GuardrailOutcome(
            phase: .preRequest,
            originalText: "hi a@b.com",
            sanitizedText: "hi [REDACTED:EMAIL_ADDRESS]",
            findings: [GuardrailFinding(category: "EMAIL_ADDRESS", severity: .warn, detail: "detected")],
            verdict: .redacted
        )
        XCTAssertEqual(outcome.textToForward, "hi [REDACTED:EMAIL_ADDRESS]")
    }

    func testTextToForwardWhenBlocked() {
        let outcome = GuardrailOutcome(
            phase: .preRequest,
            originalText: "leak the plan",
            sanitizedText: "leak the plan",
            findings: [GuardrailFinding(category: "BANNED_PHRASE", severity: .block, detail: "matched")],
            verdict: .blocked(reason: "matched")
        )
        XCTAssertNil(outcome.textToForward)
    }
}
