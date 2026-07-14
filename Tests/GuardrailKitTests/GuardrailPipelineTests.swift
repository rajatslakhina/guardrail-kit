import XCTest
@testable import GuardrailKit

private struct FixedRangeDetector: PIIDetector, Sendable {
    let category: PIICategory
    let lowerOffset: Int
    let upperOffset: Int

    func findMatches(in text: String) -> [PIIMatch] {
        let lower = text.index(text.startIndex, offsetBy: lowerOffset)
        let upper = text.index(text.startIndex, offsetBy: upperOffset)
        let range = lower..<upper
        return [PIIMatch(category: category, range: range, matchedText: String(text[range]))]
    }
}

final class GuardrailPipelineTests: XCTestCase {
    func testScreenRequestAllowsCleanText() async {
        let pipeline = GuardrailPipeline()
        let outcome = await pipeline.screenRequest("nothing sensitive here")
        XCTAssertEqual(outcome.verdict, .allow)
        XCTAssertEqual(outcome.sanitizedText, outcome.originalText)
        XCTAssertTrue(outcome.findings.isEmpty)
        XCTAssertEqual(outcome.phase, .preRequest)
    }

    func testScreenRequestRedactsPII() async {
        let pipeline = GuardrailPipeline()
        let outcome = await pipeline.screenRequest("email me at jane@example.com please")
        XCTAssertEqual(outcome.verdict, .redacted)
        XCTAssertTrue(outcome.sanitizedText.contains("[REDACTED:EMAIL_ADDRESS]"))
        XCTAssertFalse(outcome.sanitizedText.contains("jane@example.com"))
        XCTAssertEqual(outcome.findings.count, 1)
    }

    func testScreenResponseRedactsPII() async {
        let pipeline = GuardrailPipeline()
        let outcome = await pipeline.screenResponse("call 555-123-4567 to confirm")
        XCTAssertEqual(outcome.phase, .postResponse)
        XCTAssertEqual(outcome.verdict, .redacted)
        XCTAssertTrue(outcome.sanitizedText.contains("[REDACTED:PHONE_NUMBER]"))
    }

    func testScreenRequestBlocksOnPolicyRule() async {
        let policy = GuardrailPolicy(
            piiDetectors: [],
            contentPolicyRules: [BannedPhraseRule(phrases: [.init("top secret", severity: .block)])]
        )
        let pipeline = GuardrailPipeline(policy: policy)
        let outcome = await pipeline.screenRequest("this is top secret information")
        guard case .blocked(let reason) = outcome.verdict else {
            return XCTFail("expected blocked verdict")
        }
        XCTAssertEqual(reason, "matched banned phrase \"top secret\"")
        XCTAssertNil(outcome.textToForward)
    }

    func testBlockedFindingTakesPriorityOverRedaction() async {
        let policy = GuardrailPolicy(
            contentPolicyRules: [BannedPhraseRule(phrases: [.init("top secret", severity: .block)])]
        )
        let pipeline = GuardrailPipeline(policy: policy)
        let outcome = await pipeline.screenRequest("top secret: email jane@example.com")
        guard case .blocked = outcome.verdict else {
            return XCTFail("expected blocked verdict even though PII was also present")
        }
    }

    func testMultipleNonOverlappingMatchesAreAllRedacted() async {
        let pipeline = GuardrailPipeline()
        let outcome = await pipeline.screenRequest("jane@example.com or 555-123-4567")
        XCTAssertEqual(outcome.findings.count, 2)
        XCTAssertTrue(outcome.sanitizedText.contains("[REDACTED:EMAIL_ADDRESS]"))
        XCTAssertTrue(outcome.sanitizedText.contains("[REDACTED:PHONE_NUMBER]"))
    }

    func testOverlappingMatchesKeepOnlyTheFirstByPosition() async {
        let text = "abcdefgh"
        let policy = GuardrailPolicy(
            piiDetectors: [
                FixedRangeDetector(category: .emailAddress, lowerOffset: 0, upperOffset: 6),
                FixedRangeDetector(category: .phoneNumber, lowerOffset: 2, upperOffset: 8)
            ],
            contentPolicyRules: []
        )
        let pipeline = GuardrailPipeline(policy: policy)
        let outcome = await pipeline.screenRequest(text)
        XCTAssertEqual(outcome.findings.count, 1)
        XCTAssertEqual(outcome.findings[0].category, PIICategory.emailAddress.rawValue)
        XCTAssertEqual(outcome.sanitizedText, "[REDACTED:EMAIL_ADDRESS]gh")
    }

    func testRecorderReceivesOneEventPerScreening() async {
        let recorder = InMemoryGuardrailEventRecorder()
        let pipeline = GuardrailPipeline(recorder: recorder)
        _ = await pipeline.screenRequest("clean text")
        _ = await pipeline.screenResponse("also clean")
        let events = await recorder.recordedEvents
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].phase, .preRequest)
        XCTAssertEqual(events[1].phase, .postResponse)
    }

    func testNoRecorderConfiguredDoesNotCrash() async {
        let pipeline = GuardrailPipeline(recorder: nil)
        let outcome = await pipeline.screenRequest("clean text")
        XCTAssertEqual(outcome.verdict, .allow)
    }
}
