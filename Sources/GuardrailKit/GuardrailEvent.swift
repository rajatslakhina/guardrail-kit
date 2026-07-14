import Foundation

/// One trace record of a guardrail screening a piece of text — the audit
/// trail every redaction or block should leave behind.
public struct GuardrailEvent: Sendable, Equatable {
    public let timestamp: Date
    public let phase: GuardrailPhase
    public let verdict: GuardrailVerdict
    public let findingCount: Int

    public init(timestamp: Date, phase: GuardrailPhase, verdict: GuardrailVerdict, findingCount: Int) {
        self.timestamp = timestamp
        self.phase = phase
        self.verdict = verdict
        self.findingCount = findingCount
    }
}
