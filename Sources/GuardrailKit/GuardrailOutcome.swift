/// The full result of screening one piece of text through a
/// ``GuardrailPipeline``: the original text, the sanitized text, every
/// finding raised, and the resulting verdict.
public struct GuardrailOutcome: Sendable, Equatable {
    public let phase: GuardrailPhase
    public let originalText: String
    public let sanitizedText: String
    public let findings: [GuardrailFinding]
    public let verdict: GuardrailVerdict

    public init(
        phase: GuardrailPhase,
        originalText: String,
        sanitizedText: String,
        findings: [GuardrailFinding],
        verdict: GuardrailVerdict
    ) {
        self.phase = phase
        self.originalText = originalText
        self.sanitizedText = sanitizedText
        self.findings = findings
        self.verdict = verdict
    }

    /// The text a caller should actually forward downstream: the sanitized
    /// text, unless the pipeline blocked the request entirely, in which case
    /// there is nothing safe to forward.
    public var textToForward: String? {
        switch verdict {
        case .blocked:
            return nil
        case .allow, .redacted:
            return sanitizedText
        }
    }
}
