import Foundation
import XCTest
@testable import GuardrailKit

final class GuardrailEventRecorderTests: XCTestCase {
    func testRecordsEventsInOrder() async {
        let recorder = InMemoryGuardrailEventRecorder()
        let first = GuardrailEvent(timestamp: Date(), phase: .preRequest, verdict: .allow, findingCount: 0)
        let second = GuardrailEvent(timestamp: Date(), phase: .postResponse, verdict: .redacted, findingCount: 1)

        await recorder.record(first)
        await recorder.record(second)

        let events = await recorder.recordedEvents
        XCTAssertEqual(events, [first, second])
    }

    func testStartsEmpty() async {
        let recorder = InMemoryGuardrailEventRecorder()
        let events = await recorder.recordedEvents
        XCTAssertTrue(events.isEmpty)
    }
}
