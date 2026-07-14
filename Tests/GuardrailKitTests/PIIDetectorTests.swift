import XCTest
@testable import GuardrailKit

final class PIIDetectorTests: XCTestCase {
    func testPIICategoryRawValues() {
        XCTAssertEqual(PIICategory.emailAddress.rawValue, "EMAIL_ADDRESS")
        XCTAssertEqual(PIICategory.phoneNumber.rawValue, "PHONE_NUMBER")
        XCTAssertEqual(PIICategory.creditCard.rawValue, "CREDIT_CARD")
        XCTAssertEqual(PIICategory.socialSecurityNumber.rawValue, "SOCIAL_SECURITY_NUMBER")
    }

    func testPIIMatchEquatable() {
        let text = "a@b.com"
        let range = text.startIndex..<text.endIndex
        let lhs = PIIMatch(category: .emailAddress, range: range, matchedText: text)
        let rhs = PIIMatch(category: .emailAddress, range: range, matchedText: text)
        XCTAssertEqual(lhs, rhs)
    }

    func testEmailAddressDetectorFindsMatch() {
        let detector = EmailAddressDetector()
        XCTAssertEqual(detector.category, .emailAddress)
        let text = "contact jane.doe@example.com now"
        let matches = detector.findMatches(in: text)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].matchedText, "jane.doe@example.com")
    }

    func testEmailAddressDetectorNoMatch() {
        XCTAssertTrue(EmailAddressDetector().findMatches(in: "no email here").isEmpty)
    }

    func testPhoneNumberDetectorFindsMatch() {
        let detector = PhoneNumberDetector()
        XCTAssertEqual(detector.category, .phoneNumber)
        let matches = detector.findMatches(in: "call 555-123-4567 please")
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].matchedText, "555-123-4567")
    }

    func testPhoneNumberDetectorNoMatch() {
        XCTAssertTrue(PhoneNumberDetector().findMatches(in: "no phone here").isEmpty)
    }

    func testCreditCardDetectorFindsMatch() {
        let detector = CreditCardDetector()
        XCTAssertEqual(detector.category, .creditCard)
        let matches = detector.findMatches(in: "card 4111-1111-1111-1111 on file")
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].matchedText, "4111-1111-1111-1111")
    }

    func testCreditCardDetectorNoMatch() {
        XCTAssertTrue(CreditCardDetector().findMatches(in: "no card here").isEmpty)
    }

    func testSocialSecurityNumberDetectorFindsMatch() {
        let detector = SocialSecurityNumberDetector()
        XCTAssertEqual(detector.category, .socialSecurityNumber)
        let matches = detector.findMatches(in: "ssn 123-45-6789 on file")
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].matchedText, "123-45-6789")
    }

    func testSocialSecurityNumberDetectorNoMatch() {
        XCTAssertTrue(SocialSecurityNumberDetector().findMatches(in: "no ssn here").isEmpty)
    }
}
