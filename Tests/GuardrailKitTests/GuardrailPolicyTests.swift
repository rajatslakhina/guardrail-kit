import XCTest
@testable import GuardrailKit

final class GuardrailPolicyTests: XCTestCase {
    func testDefaultPIIDetectorsCoverAllBuiltInCategories() {
        let categories = Set(GuardrailPolicy.defaultPIIDetectors.map(\.category))
        XCTAssertEqual(categories, Set(PIICategory.allCases))
    }

    func testDefaultRedactionPlaceholderFormat() {
        let policy = GuardrailPolicy()
        XCTAssertEqual(policy.redactionPlaceholder(.emailAddress), "[REDACTED:EMAIL_ADDRESS]")
    }

    func testCustomPolicyStoresProvidedValues() {
        let rule = BannedPhraseRule(phrases: [.init("x", severity: .block)])
        let policy = GuardrailPolicy(
            piiDetectors: [EmailAddressDetector()],
            contentPolicyRules: [rule],
            redactionPlaceholder: { _ in "***" }
        )
        XCTAssertEqual(policy.piiDetectors.count, 1)
        XCTAssertEqual(policy.contentPolicyRules.count, 1)
        XCTAssertEqual(policy.redactionPlaceholder(.creditCard), "***")
    }
}
