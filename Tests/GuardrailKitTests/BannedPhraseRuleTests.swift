import XCTest
@testable import GuardrailKit

final class BannedPhraseRuleTests: XCTestCase {
    func testNoMatchReturnsNil() {
        let rule = BannedPhraseRule(phrases: [.init("secret", severity: .block)])
        XCTAssertNil(rule.evaluate("nothing sensitive here"))
    }

    func testMatchIsCaseInsensitive() {
        let rule = BannedPhraseRule(phrases: [.init("Secret Plan", severity: .block)])
        let finding = rule.evaluate("this mentions the SECRET PLAN explicitly")
        XCTAssertEqual(finding?.severity, .block)
        XCTAssertEqual(finding?.category, "BANNED_PHRASE")
        XCTAssertEqual(finding?.detail, "matched banned phrase \"Secret Plan\"")
    }

    func testFirstMatchingPhraseWins() {
        let rule = BannedPhraseRule(phrases: [
            .init("alpha", severity: .warn),
            .init("beta", severity: .block)
        ])
        let finding = rule.evaluate("this text has both alpha and beta")
        XCTAssertEqual(finding?.severity, .warn)
    }
}
