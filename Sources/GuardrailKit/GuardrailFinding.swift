/// How serious a guardrail finding is, in increasing order of urgency.
public enum GuardrailSeverity: Int, Sendable, Equatable, Comparable, CaseIterable {
    case info = 0
    case warn = 1
    case block = 2

    public static func < (lhs: GuardrailSeverity, rhs: GuardrailSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// A single thing a guardrail flagged, independent of whether it came from a
/// PII detector or a content policy rule.
public struct GuardrailFinding: Sendable, Equatable {
    public let category: String
    public let severity: GuardrailSeverity
    public let detail: String

    public init(category: String, severity: GuardrailSeverity, detail: String) {
        self.category = category
        self.severity = severity
        self.detail = detail
    }
}
